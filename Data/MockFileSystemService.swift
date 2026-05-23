//
//  MockFileSystemService.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/26/26.
//

import Foundation
import Combine
import SwiftUI

class MockFileSystemService: FileSystemServiceProtocol {
    
    func startStreamingScan() -> AsyncStream<FileSystemService.ScanEvent> {
        return AsyncStream(FileSystemService.ScanEvent.self) { continuation in
            Task {
                // Simulate scanning different routes
                let paths = ["/Users/demo/Library/Caches", "/Users/demo/.Trash", "/var/folders/logs"]
                
                for path in paths {
                    continuation.yield(.scanning(path: path))
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seg
                }
                
                // Simulate junk files
                let mockItems = [
                    JunkItem(name: "Cache de Aplicación", category: .cache, paths: [URL(fileURLWithPath: "/ruta/a/la/cache")], size: 23 * 1024),
                    JunkItem(name: "Contenido de Papelera", category: .trash, paths: [URL(fileURLWithPath: "/ruta/a/papelera")], size: 10 * 1024),
                    JunkItem(name: "Logs de Aplicación", category: .logs, paths: [URL(fileURLWithPath: "/ruta/a/logs")], size: 50 * 1024),
                    JunkItem(name: "Contenido de Papelera", category: .trash, paths: [URL(fileURLWithPath: "/ruta/a/papelera")], size: 10 * 1024)
                ]
                
                for item in mockItems {
                    continuation.yield(.found(item: item))
                    try? await Task.sleep(nanoseconds: 300_000_000)
                }
                
                continuation.yield(.finished)
                continuation.finish()
            }
        }
    }
    
    func deleteItems(_ items: [JunkItem], onProgress: @Sendable @escaping (Double) async -> Void) async throws -> Bool {
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seg
        print("MOCK: would have been erased \(items.count) items")
        return true
    }
}


//#Preview {
//    // Injected the Mock instead of the real service
//    let mockService = MockFileSystemService()
//    let viewModel = EngineViewModel(service: mockService)
//    
//    ContentView()
//        .environmentObject(viewModel)
//}
