//
//  ConfigurationRepository.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/21/26.
//

import Foundation

class ConfigurationRepository {
    static let shared = ConfigurationRepository()
    var definitions: [JunkDefinition] = []
    
    init() {
        definitions = loadDefinitions()
    }
    
    /// Load definitions from JSON
    private func loadDefinitions() -> [JunkDefinition] {
        guard let url = Bundle.main.url(forResource: "junk_definitions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([JunkDefinition].self, from: data) else { return [] }
        return decoded
    }
    
    struct SanitizerJSON {
        /// Routes that should NEVER be touched by NovaClean
        private static let blacklistedPrefixes = [
            "/System",
            "/bin",
            "/sbin",
            "/etc",
            "/usr/bin",
            "/usr/sbin",
            "/Library/SystemProfiler",
            "/private/var",
            "/private/etc",
            "/private/sbin",
            "/private/tmp"
        ]
        
        
        // risky folders
        private static let protectedUserPaths = [
            "", "/", "/Users", "/Users/",
            (NSHomeDirectory() as NSString).standardizingPath
        ]
        
        static func isSafe(path: String) -> Bool {
            // 1. Expand and standardize the entry path
            let expandedPath = (path as NSString).expandingTildeInPath
            let inputURL = URL(fileURLWithPath: expandedPath)
            
            // 2. Symlink resolution: Get the REAL destination on the disk
            let resolvedPath = inputURL.resolvingSymlinksInPath().path
            let standardized = (resolvedPath as NSString).standardizingPath.lowercased()
            
            // 3. Blocking empty/root routes
            if standardized.isEmpty || protectedUserPaths.contains(standardized) {
                return false
            }
            
            // 4. Directory Traversal Prevention (../../ attacks)
            if path.contains("..") { return false }
            
            // 5. Blocking critical system prefixes
            for prefix in blacklistedPrefixes {
                if standardized.hasPrefix(prefix) { return false }
            }
            
            /// 6. Make sure we're not trying to delete vital Apple folders
            let criticalFolders = [
                "assistant", "cloudkit", "cloudtelemetry", "baseband", "spotlight", "identityservices", "protected", "clouddocs", "metadata"
            ]
            for folder in criticalFolders { if standardized.contains(folder) { return false } }
            
            /// 7. Block anything from com.apple.* (except Safari, which is safe)
            if standardized.contains("/com.apple.") && !standardized.contains("safari") {
                //print("🛡️ Avoiding potentially dangerous path \(standardized)")
                return false
            }
            
            return true
        }
    }
}
