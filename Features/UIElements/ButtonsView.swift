//
//  ButtonsView.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import SwiftUI

struct ButtonsView: View {
    var body: some View {
        //
    }
}

enum ButtonVariant {
    case primary
    case secondary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary:      return .btnPrimary
        case .secondary:    return .btnSecondary.opacity(0.5)
        case .destructive:  return .btnDestructive.opacity(0.9)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .destructive: return .white
        case .secondary:             return .white
        }
    }
    
    var borderColor: Color {
        switch self {
        case .secondary: return .primary.opacity(0.3)
        default:         return .clear
        }
    }
}

struct IconButton: View {
    let title: String
    let icon: String
    let variant: ButtonVariant
    let action: () -> Void
    
    var isDisabled: Bool = false
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(variant.foregroundColor)
                
                Text(isLoading ? "Scanning..." : title)
                    .font(.headline)
                    .foregroundStyle(variant.foregroundColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 100)
        }
        .buttonStyle(IconButtonStyle(
            variant: variant,
            isDisabled: isDisabled,
            isLoading: isLoading
        ))
        .disabled(isDisabled || isLoading)
    }
}

struct IconButtonStyle: ButtonStyle {
    let variant: ButtonVariant
    let isDisabled: Bool
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(variant.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(variant.borderColor, lineWidth: variant == .secondary ? 2 : 0)
                    )
            )
            .shadow(
                color: isDisabled ? .clear : variant.backgroundColor.opacity(0.5),
                radius: 10,
                x: 0,
                y: 0
            )
            .opacity(isDisabled ? 0.55 : 1.0)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    IconButton(title: "Scan & Clean", icon: "sparkles", variant: .primary, action: { }, isDisabled: false)
        .frame(width: 400, height: 300)
    
    IconButton(title: "Scan & Clean", icon: "sparkles", variant: .destructive, action: { }, isDisabled: false)
        .frame(width: 400, height: 300)
    
    IconButton(title: "Scan & Clean", icon: "sparkles", variant: .secondary, action: { }, isDisabled: false)
        .frame(width: 400, height: 300)
}
