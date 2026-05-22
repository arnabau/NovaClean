//
//  CleanUpService.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//
// Service Implementation (Data access layer). This is where the security logic and access to the file system reside.

import Foundation
import Combine

actor FileSystemService: FileSystemServiceProtocol {
    // ================== TESTING MODE =========================
    private let isReadOnlyMode = false /// Switch to false only in production
    // =========================================================
    
    private var hasAnyError = false
    
    private var fileManager = FileManager.default
    private let sanitizer: ConfigurationRepository
    
    enum ScanEvent {
        case scanning(path: String)
        case found(item: JunkItem)
        case error(ErrorManager) /// ErrorManager Integration
        case finished
    }
    
    /// dependency inyection
    init(sanitizer: ConfigurationRepository) {
        //self.fileManager = fileManager
        self.sanitizer = sanitizer
//        self.createDummyFiles()
    }
    
    // ******************************
    // create junk files for testing
//    func createDummyFiles() {
//        let path = "/tmp/novaclean_test"
//        try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
//        for i in 1...5 {
//            let content = "Just dummy text \(i)"
//            let fileURL = URL(fileURLWithPath: "\(path)/test_file_\(i).txt")
//            try? content.write(to: fileURL, atomically: true, encoding: .utf8)
//        }
//    }
    
    /// start scan process
    func startStreamingScan() -> AsyncStream<ScanEvent> {
        AsyncStream { continuation in
            Task {
                let definitions = await sanitizer.definitions
                
                for def in definitions {
                    continuation.yield(.scanning(path: "Analyzing \(await def.category.displayName)..."))
                    
                    for itemDef in def.items {
                        guard await ConfigurationRepository.SanitizerJSON.isSafe(path: itemDef.path) else {
                            //print("⚠️ NovaClean blocked a suspicious route: \(itemDef.path)")
                            continue
                        }
                        
                        let resolvedURLs = resolvePath(itemDef.path)
                        if resolvedURLs.isEmpty {
                            await Task.yield()
                            continue
                        }
                        
                        let (size, count) = await calculateSize(for: resolvedURLs)
                        
                        if size > 0 || def.category == .trash {
                            let isHighRisk = await def.category.isHighRisk
                            let item = JunkItem(
                                name: itemDef.name,
                                category: def.category,
                                paths: resolvedURLs,
                                size: size,
                                fileCount: count,
                                isSelected: !isHighRisk /// unchecked by default
                            )
                            continuation.yield(.found(item: item))
                        }
                    }
                    try? await Task.sleep(nanoseconds: 20_000_000) /// 0.02s UI fluency
                }
                continuation.yield(.finished)
                continuation.finish()
            }
        }
    }
    
    /// Delete selected files
    func deleteItems(_ items: [JunkItem]) async throws -> Bool {
        let overallSuccess = true
        
        for item in items where item.isSelected {
            /// "special case" --> trashcan. We don't want to delete the folder but empty it
            if item.category == .trash && !isReadOnlyMode {
                await emptyTrashManually()
                continue /// jump to the next item
            }
            
            for url in item.paths {
                /// let's do another path check just in case to avoid any security risk
                guard await ConfigurationRepository.SanitizerJSON.isSafe(path: url.path) else { continue }
                
                do {
                    if fileManager.fileExists(atPath: url.path) {
                        if !isReadOnlyMode {
                            try fileManager.removeItem(at: url)
                            /// Optional: Recreate empty directory to prevent apps from crashing
                            if item.category != .trash {
                                try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                            }
                        }
                    }
                } catch {
                    //hasAnyError = true
                    //overallSuccess = false
                    let errorMessage = error.localizedDescription
                    print("⚠️ Error deleting file \(url.lastPathComponent): \(errorMessage)")
                    continue
                }
                
                await Task.yield()
            }
        }
        
//        if hasAnyError {
//            // show message at the end...
//        }
        
        return overallSuccess
    }
    
    /// Empty trash manually. A "nasty" way to do it
    private func emptyTrashManually() async {
        let trashURL = URL(fileURLWithPath: ("~/.Trash" as NSString).expandingTildeInPath)
        
        guard let enumerator = fileManager.enumerator(
            at: trashURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return }
        
        while let fileURL = enumerator.nextObject() as? URL {
//            if isReadOnlyMode {
//                print("🛡️ [READ-ONLY] Ignoring: \(fileURL.lastPathComponent)")
//                continue
//            }
            if !isReadOnlyMode {
                do {
                    try fileManager.removeItem(at: fileURL)
                    await Task.yield()
                } catch let error {
                    hasAnyError = true
                    print("Error: cannot delete \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    continue
                }
            }
        }
        
        if hasAnyError {
            // show message at the end...
        }
    }
    
    
    // MARK: - Path Helper (Wildcards & Tilde)
    private func resolvePath(_ path: String) -> [URL] {
        let expandedPath = (path as NSString).expandingTildeInPath
        if !expandedPath.contains("*") {
            let url = URL(fileURLWithPath: expandedPath)
            return fileManager.fileExists(atPath: expandedPath) ? [url] : []
        }
        
        /// Recursive logic for wildcards
        return resolveWildcards(components: expandedPath.components(separatedBy: "/"), current: "/")
    }
    
    
    private func resolveWildcards(components: [String], current: String) -> [URL] {
        var parts = components
        if parts.first?.isEmpty ?? false { parts.removeFirst() }
        guard let first = parts.first else { return [URL(fileURLWithPath: current)] }
        
        let remaining = Array(parts.dropFirst())
        var results: [URL] = []
        
        if first == "*" {
            let url = URL(fileURLWithPath: current)
            
            if let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
                options: [.skipsPackageDescendants, .skipsHiddenFiles, .skipsSubdirectoryDescendants] // <-- Avoid infinite recursion
            ){
                for case let contentURL as URL in enumerator {
                    results.append(contentsOf: resolveWildcards(
                        components: remaining,
                        current: contentURL.path
                    ))
                }
            }
        } else {
            let next = (current as NSString).appendingPathComponent(first)
            if fileManager.fileExists(atPath: next) {
                results.append(contentsOf: resolveWildcards(components: remaining, current: next))
            }
        }
        return results
    }
    
    
    // MARK: - Calculate folder size
    private func calculateSize(for urls: [URL]) async -> (Int64, Int) {
        var totalSize: Int64 = 0
        var totalFiles = 0
        let keys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey]
        
        for url in urls {
            guard let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles, .skipsPackageDescendants])
            else { continue }
            
            while let fileURL = enumerator.nextObject() as? URL {
                if let res = try? fileURL.resourceValues(forKeys: Set(keys)),
                   res.isDirectory == false {
                    totalSize += Int64(res.fileSize ?? 0)
                    totalFiles += 1
                }
                
                /// Release the thread every 500 files to maintain a smooth UI
                if totalFiles % 500 == 0 { await Task.yield() }
            }
        }
        return (totalSize, totalFiles)
    }
    
}

