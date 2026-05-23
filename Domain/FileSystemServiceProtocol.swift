//
//  FileSystemServiceProtocol.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/25/26.
//
// Abstraction. The ViewModel will not know the FileManager, it will only know this contract.

import Foundation

/// Service contract: Any class that implements this protocol can be used by the ViewModel.
protocol FileSystemServiceProtocol: Sendable {
    func startStreamingScan() async -> AsyncStream<FileSystemService.ScanEvent>
    func deleteItems(_ items: [JunkItem], onProgress: @Sendable @escaping (Double) async -> Void) async throws -> Bool
}
