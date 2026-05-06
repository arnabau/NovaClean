//
//  SystemNavigator.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/21/26.
//

import Foundation
import AppKit

enum SystemNavigator {
    /// Specific System Settings Panels (macOS 13+)
    enum SettingsPanel: String {
        case battery = "x-apple.systempreferences:com.apple.Battery-Settings.extension"
        case fullDiskAccess = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        case general = "x-apple.systempreferences:com.apple.Preference.General"
        case storage = "x-apple.systempreferences:com.apple.settings.Storage"
        case loginItems = "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
    }
    
    /// System utility applications
    enum SystemApp: String {
        case activityMonitor = "com.apple.ActivityMonitor"
        case terminal = "com.apple.Terminal"
        case diskUtility = "com.apple.DiskUtility"
        case console = "com.apple.Console"
    }
    
    // MARK: - Navigation Methods
    
    /// Open a specific panel in the System Settings
    static func open(_ panel: SettingsPanel) {
        guard let url = URL(string: panel.rawValue) else { return }
        NSWorkspace.shared.open(url)
    }
    
    /// Launch a system application using its Bundle ID
    static func launch(_ app: SystemApp) {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.rawValue) else {
            print("NovaClean Error: The app could not be found. \(app.rawValue)")
            return
        }
        
        let config = NSWorkspace.OpenConfiguration()
        config.addsToRecentItems = false /// Do not clutter the user's dock unless necessary
        
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                print("NovaClean Error: Launch failure \(app): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - File System Actions
    
    /// Open Finder with the file or folder selected.
    /// - Parameter path: Full path
    static func revealInFinder(at path: String) {
        /// 1. Expand the tilde in case a path like "~/Downloads" is present
        let expandedPath = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        
        /// If it's the trash we simply open the folder instead of "selecting" a non-existent file within it
        if path.contains(".Trash") {
            NSWorkspace.shared.open(url)
            return
        }
        
        /// 2. Check if the file actually exists so we don't open Finder with a blank screen
        guard FileManager.default.fileExists(atPath: expandedPath) else {
            print("NovaClean Error: A non-existent route cannot be revealed: \(expandedPath)")
            return
        }
        
        /// 3. Use a modern API to select the file in the Finder
        /// NSWorkspace: can open almost anything, apps, folders, files, etc
        /// Opens the containing folder and highlights the specified file/folder
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    
    /// Empty trash Apple's way (AppleScript)...not working anymore?
//    func emptyTrash() {
//        let script = "tell application \"Finder\" to empty trash"
//        if let appleScript = NSAppleScript(source: script) {
//            var error: NSDictionary?
//            appleScript.executeAndReturnError(&error)
//
//            if let err = error {
//                print("Error al vaciar papelera: \(err)")
//            }
//        }
//    }
}
