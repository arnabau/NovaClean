//
//  CleanupResultsView.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/28/26.
//

import SwiftUI

struct CleanupResultsView: View {
    let size: Int64
    let fileCount: Int
//    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("cleanning_done_message".localized)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("cleanning_done_description".localized)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("cleanning_error_message".localized)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            
            HStack(spacing: 20) {
                CardView(title: "cleanning_done_summary".localized, icon: "externaldrive.fill", color: .blue) {
                    Text(Formatters.formatBytes(size))
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.labelSecondary)
                }
                .padding(2)
                
                CardView(title: "cleanning_done_total_files".localized, icon: "doc.fill", color: .purple) {
                    Text("\(fileCount)")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.labelSecondary)
                }
                .padding(2)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    CleanupResultsView(size: 1024, fileCount: 200)
}
