//
//  CloudBackground.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import Foundation
import SwiftUI

struct CloudBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 1.5],
                [0, 1], [0.5, 1], [1, 1]
            ], colors: colorScheme == .dark ? [
                .blue.opacity(0.4), .indigo.opacity(0.3), .blue.opacity(0.2),
                .black.opacity(0.3), .teal.opacity(0.3), .black,
                .blue.opacity(0.2), .indigo.opacity(0.5), .blue.opacity(0.2)
            ] : [
                .blue.opacity(0.3), .blue.opacity(0.1), .indigo.opacity(0.2),
                .blue.opacity(0.2), .blue.opacity(0.1), .green.opacity(0.3),
                .blue.opacity(0.2), .indigo.opacity(0.2), .teal.opacity(0.5)
            ])
            .ignoresSafeArea()
            
//            // Fondo base oscuro
//            Color(red: 0.07, green: 0.13, blue: 0.32)
//                .ignoresSafeArea()
//            
//            // Main gradient
//            LinearGradient(colors: [.blue.opacity(0.2), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
//            .ignoresSafeArea()
//            
//            RadialGradient(
//                colors: [
//                    Color.blue.opacity(0.28),
//                    Color.cyan.opacity(0.15),
//                    Color.clear
//                ],
//                center: .center,
//                startRadius: 120,
//            // Central Glow (clow effect)
//                endRadius: 650
//            )
//            .blur(radius: 85)
//            .ignoresSafeArea()
//            
//            // Glow
//            RadialGradient(
//                colors: [
//                    Color.white.opacity(0.10),
//                    Color.clear
//                ],
//                center: .center,
//                startRadius: 80,
//                endRadius: 500
//            )
//            .blur(radius: 110)
//            .ignoresSafeArea()
        }
    }
}


#Preview {
    CloudBackgroundView()
}
