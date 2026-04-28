//
//  NovaCleanApp.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import SwiftUI

@main
struct NovaCleanApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
//    let viewModel: EngineViewModel
//    init() {
//        // Estrategia: Si estamos en DEBUG, usamos el Mock
//#if DEBUG
//        let service = MockFileSystemService()
//#else
//        let service = FileSystemService(sanitizer: ConfigurationRepository.shared)
//#endif
//        
//        self.viewModel = EngineViewModel(service: service)
//    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(themeManager)
//                    .environmentObject(viewModel)
                    .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                    .background(CloudBackgroundView())
                    .overlay(alignment: .topTrailing) {
                        FloatingThemeSwitcher(themeManager: themeManager)
                            .padding(2)
                    }
                    .animation(.easeInOut, value: themeManager.selectedTheme)
            }
        }
    }
}
