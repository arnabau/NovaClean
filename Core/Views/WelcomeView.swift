//
//  WelcomeView.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/28/26.
//

import SwiftUI

struct WelcomeView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.variableColor.reversing, options: .repeating)
            }
            
            VStack(spacing: 12) {
                Text("main_view_header_title".localized)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.labelPrimary)
                
                Text("main_view_header_description".localized)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .lineSpacing(4)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "shield.checkered")
                    .font(.caption)
                Text("Secure • Private • Local")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .tracking(1.2)
            }
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.top, 10)
        }
        .padding(5)
        .frame(maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primary.opacity(0.02))
                .padding(5)
        )
    }
}

#Preview {
    WelcomeView()
}
