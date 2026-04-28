//
//  UseCase.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import Foundation

enum JunkCategory: String, CaseIterable, Identifiable, Codable {
    case trash, browser, dev, logs, cache, apps, advanced, test
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .trash: return "System Trash"
        case .browser: return "Browsers"
        case .dev: return "Development"
        case .logs: return "Logs & Reports"
        case .cache: return "System cache"
        case .apps: return "Apps"
        case .advanced: return "Advanced cleanup"
        case .test: return "Test"
        }
    }
    
    var icon: String {
        switch self {
        case .trash: return "trash"
        case .browser: return "safari"
        case .dev: return "hammer"
        case .logs: return "doc.text"
        case .cache: return "shippingbox"
        case .apps: return "apple.terminal.on.rectangle.fill"
        case .advanced: return "exclamationmark.triangle.fill"
        case .test: return "archivebox.fill" /// just for testing
        }
    }
    
    var isHighRisk: Bool { return self == .advanced }
}

struct JunkItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: JunkCategory
    let paths: [URL]
    var size: Int64 = 0
    var fileCount: Int = 0
    var isSelected: Bool = true
    var isCleaned: Bool = false
}

/// Definitions for JSON
struct JunkDefinition: Codable {
    let category: JunkCategory
    let items: [PathDefinition]
}

struct PathDefinition: Codable {
    let name: String
    let path: String
}
