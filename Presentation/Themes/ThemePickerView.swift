//
//  ThemePickerView.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/22/26.
//

import Foundation
import SwiftUI

struct ThemePickerView: View {
    @ObservedObject var themeManager: ThemeManager
    
    private var safeThemeBinding: Binding<AppTheme> {
        Binding(
            get: {
                return themeManager.selectedTheme
            },
            set: { newValue in
                DispatchQueue.main.async {
                    themeManager.selectedTheme = newValue
                }
            }
        )
    }
    
    var body: some View {
        //
    }
}

struct FloatingThemeSwitcher: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        Button {
            toggleTheme()
        } label: {
            Image(systemName: themeManager.selectedTheme == .light ? "moon.fill" : "sun.max.fill")
                .font(.title2)
                .foregroundColor(.white)
                .rotationEffect(.degrees(themeManager.selectedTheme == .dark ? 180 : 0))
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: themeManager.selectedTheme)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(themeManager.selectedTheme == .light ? Color.blue.opacity(0.90) : Color.orange.opacity(0.90))
                        .shadow(radius: 4)
                )
                .padding(10)
        }
        .tint(.clear)
        .buttonStyle(PlainButtonStyle())
        .focusEffectDisabled()
    }
    
    private func toggleTheme() {
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                themeManager.selectedTheme = (themeManager.selectedTheme == .light ? .dark : .light)
            }
        }
    }
}


#Preview {
    FloatingThemeSwitcher(themeManager: .shared)
}
