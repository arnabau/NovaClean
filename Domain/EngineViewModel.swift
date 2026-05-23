//
//  EngineViewModel.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//
// The orchestrator (Presentation layer). It only manages the UI state and calls the protocol

import Foundation
import Combine
import SwiftUI

@MainActor
class EngineViewModel: ObservableObject {
    @Published var findings: [JunkItem] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var progress: Double = 0.0
    @Published var hasFDA: Bool = false /// Full Disk Access
    @Published var statusText = "text_ready_scan".localized
    
    @Published var showResultsScreen = false
    @Published var lastCleanupSize: Int64 = 0
    @Published var lastCleanupCount: Int = 0
    
    @Published var activeError: ErrorManager?
    @Published var showErrorAlert: Bool = false
    
    func handleError(_ error: Any) {
        if let errManager = error as? ErrorManager {
            self.activeError = errManager
        } else if let nsError = error as? NSError {
            self.activeError = .unknown(nsError)
        } else if let stringError = error as? String {
            // If someone passed a String by mistake, we wrap it in an Unknown Error
            let customError = NSError(domain: "NovaClean", code: 0, userInfo: [NSLocalizedDescriptionKey: stringError])
            self.activeError = .unknown(customError)
        } else {
            self.activeError = .unknown(NSError(domain: "NovaClean", code: -1, userInfo: nil))
        }
        self.showErrorAlert = true
    }
    
    var selectedItemsSummary: String {
        // 1. Calculate the number of selected items
        let count = findings.filter { $0.isSelected }.count
        
        // 2. Obtain the formatted size
        let sizeString = Formatters.formatBytes(totalSelectedSize)
        
        // 3. Built the string using the localized template
        // Use NSLocalizedString to ensure it searches within .strings files
        return String(
            format: NSLocalizedString("card_selection_summary", comment: "Summary of selected items in the card"),
            count,
            sizeString
        )
    }
    
    private let service: FileSystemServiceProtocol
    /// Inject the dependency. This allows to, in the future, pass a "MockService" for unit testing without touching the actual file system
    init(service: FileSystemServiceProtocol) {
        self.service = service
        checkPermissions()
    }
    
    func UIScanProgress() async {
        isScanning = true
        findings.removeAll()
        progress = 0.0
        
        withAnimation { showResultsScreen = false }
        
        let categories = JunkCategory.allCases
        let total = Double(categories.count)
        var currentIdx = 0.0
        
        for await event in await service.startStreamingScan() {
            switch event {
            case .scanning(let text):
                statusText = text
                if text.contains("Analyzing") {
                    currentIdx += 1
                    withAnimation {
                        self.progress = currentIdx / total
                    }
                }
                
            case .found(let item):
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.findings.append(item)
                }
                
            case .finished:
                self.statusText = String(format: "scan_bytes_summary".localized, Formatters.formatBytes(findings.reduce(0){$0 + $1.size}))
                self.progress = 1.0
            case .error(_):
                let _ = "error_generic_title".localized
            }
        }
        
        isScanning = false
    }
    
    
    func UICleanProgress() async throws {
        guard !findings.isEmpty else { return }
        
        /// Only get the ones the user marked
        let selectedItems = findings.filter { $0.isSelected && !$0.isCleaned }
        
        let totalSize = selectedItems.reduce(0) { $0 + $1.size }
        let totalFiles = selectedItems.reduce(0) { $0 + $1.fileCount }
        
        isCleaning = true

        //Task {
            /// Called the service to physically delete the files
            do {
                //let success = try await service.deleteItems(selectedItems)
                let success = try await service.deleteItems(selectedItems) { @MainActor [weak self] newProgress in
                    self?.progress = newProgress
                }
                
                if success {
                    self.lastCleanupSize = totalSize
                    self.lastCleanupCount = totalFiles
                    
                    /// Instead of immediately performing another scan (which clears the entire array)
                    /// mark the items as cleared one by one with a small delay so the user sees the exit animation
                    for item in selectedItems {
                        statusText = String(format: "cleanning_in_progress".localized, item.name)
                        if let index = findings.firstIndex(where: { $0.id == item.id }) {
                            await MainActor.run {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    findings[index].isCleaned = true
                                }
                            }
                            /// short delay for a "waterfall" effect
                            try? await Task.sleep(nanoseconds: 100_000_000) /// 0.1 seg
                        }
                    }
                    
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    withAnimation { findings.removeAll(where: { $0.isCleaned }) }
                    
                    /// this will star another scan
                    //if success { await UIScanProgress() }
                    isCleaning = false
                    findings = []
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        self.statusText = "text_ready_scan".localized
                        self.showResultsScreen = true
                    }
                }
            } catch {
                let safeError = error as? ErrorManager ?? .unknown(error)
                handleError(safeError)
            }
        //}
        
        isCleaning = false
    }
    
    func resetToStart() {
        withAnimation {
            self.showResultsScreen = false
            self.findings = []
            self.statusText = "text_ready_scan".localized
        }
    }
    
    
    func checkPermissions() {
        /// The standard way to detect if we have Full Disk Access is to try to read a file that the system strictly protects (such as the TCC database or the Safari database)
        //self.hasFDA = service.hasFullDiskAccess()
        let path = (NSHomeDirectory() as NSString).appendingPathComponent("Library/Safari")
        self.hasFDA = FileManager.default.isReadableFile(atPath: path)
    }
    
    /// simple computed property
    var totalSelectedSize: Int64 {
        findings.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }
    
    
    func UIDeselectAll() {
        withAnimation(.easeInOut(duration: 0.3)) {
            for index in findings.indices {
                findings[index].isSelected = false
            }
        }
    }
    
    
    /// Allow the user, with a single click, to check "everything safe" (Caches, Trash, Logs) but leave "dangerous" unchecked (Application Support, Containers)
    func UIApplySmartSelection() {
        /// Used a smooth animation to make the checkboxes change stylishly
        withAnimation(.easeInOut(duration: 0.3)) {
            for index in findings.indices {
                let item = findings[index]
                
                /// SMART CRITERIA:
                /// 1. If it's obvious junk (Trash, Logs, Browser Cache), check it
                /// 2. If it's Advanced or the size is 0, uncheck it
                if item.category == .advanced || item.size == 0 {
                    findings[index].isSelected = false
                } else {
                    findings[index].isSelected = true
                }
            }
        }
    }
    
    // Purge memory. Does it have any positive effect?
        func purgeMemory() {
            //let process = Process.launchedProcess(launchPath: "/usr/sbin/purge", arguments: [])
            print("Purging memory...")
    
            let script = "do shell script \"/usr/sbin/purge\" with administrator privileges"
    
            if let appleScript = NSAppleScript(source: script) {
                var error: NSDictionary?
                appleScript.executeAndReturnError(&error)
    
                if let err = error {
                    print("Error al purgar memoria: \(err)")
                } else {
                    print("Memoria purgada con éxito")
                }
            }
        }
}
