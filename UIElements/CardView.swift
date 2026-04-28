//
//  CardView.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import SwiftUI

struct CardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String?
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String? = nil, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    private var cardStyle: AnyShapeStyle {
        if colorScheme == .dark {
            return AnyShapeStyle(.ultraThickMaterial)
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.appBackground.opacity(0.8), .cyan.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? color : .white.opacity(0.9))
                
                VStack(alignment: .leading, spacing: 2) {
                    if let title = title {
                        Text(title)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(colorScheme == .dark ? .labelPrimary : .white.opacity(0.9))
                    }
                }
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(cardStyle)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(
            color: color.opacity(0.15), radius: 8, x: 0, y: 8
        )
    }
}


struct GradientGlassCard<Content: View>: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let content: Content
    
    init(title: String, icon: String, gradient: LinearGradient, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            content
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.25), lineWidth: 2)
                )
        )
        .shadow(color: .blue.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}


#Preview {
    // e.g
    CardView(title: "Title for the Card", icon: "list.dash", color: .blue) {
        //
    }
    .padding(8)

    
    GradientGlassCard(
        title: "Title for the Card",
        icon: "memorychip",
        gradient: LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
    ) {
        HStack() {
            Text("lorem ipsum dolor sit amet, consectetur")
                .font(.system(size: 16))
                .padding(5)
            Spacer()
        }
    }
    .padding(8)
    
    GradientGlassCard(
        title: "Title for the Card",
        icon: "cpu",
        gradient: LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
    ) {
        HStack() {
            Text("lorem ipsum dolor sit amet, consectetur")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.9))
                .padding(5)
            Spacer()
        }
    }
    .padding(8)
}
