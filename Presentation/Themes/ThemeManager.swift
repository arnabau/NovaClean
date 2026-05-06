//
//  ThemeManager.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/22/26.
//

import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil /// system config
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("selected_theme") var selectedTheme: AppTheme = .dark
    
    static let shared = ThemeManager()
    
    private init() {}
    
    @MainActor
    func applyTheme() {
        // On macOS/iOS, the appearance change is managed via the environment. In modern SwiftUI, it's best to inject it into the WindowGroup
    }
}
