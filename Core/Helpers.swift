//
//  Helpers.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import Foundation

struct Formatters {
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        
        /// ByteCountFormatter does NOT have 'maximumFractionDigits'.
        /// To force 0 decimal places, we treat it as a String and cut it at the separator.
        let formattedString = formatter.string(fromByteCount: bytes)
        
        if let dotIndex = formattedString.firstIndex(where: { $0 == "." || $0 == "," }) {
            let unit = formattedString.components(separatedBy: " ").last ?? ""
            let value = formattedString[..<dotIndex]
            return "\(value) \(unit)"
        }
        
        return formattedString
    }
}

/// Get app's version
/// let version = Bundle.main.releaseVersionNumber ?? "1.0.0"
/// let build = Bundle.main.buildVersionNumber ?? "1"
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
