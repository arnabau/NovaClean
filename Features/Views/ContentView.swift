//
//  ContentView.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/17/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: EngineViewModel
    @State private var showConfirmAlert = false
    
    init() {
        /// DI
        let service = FileSystemService(sanitizer: ConfigurationRepository.shared)
        
        /// Inject it into the viewmodel
        /// The use of _viewModel = StateObject(...) is necessary when initializing in init
        _viewModel = StateObject(wrappedValue: EngineViewModel(service: service))
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            headerSection
            
            /// check if we have access to folders
            if !viewModel.hasFDA { permissionsBanner }
            
            contentSection
            
            actionFooter
            
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            /// When the user returns to the app after granting permission
            viewModel.checkPermissions()
        }
//        .onAppear( perform: { viewModel.checkPermissions() })
        .task { @MainActor in viewModel.checkPermissions() }
        .frame(minWidth: 600, minHeight: 450)
        .animation(.spring(), value: viewModel.hasFDA)
        .alert("alert_delete_title".localized, isPresented: $showConfirmAlert) {
            Button("alert_delete_button_cancel".localized, role: .cancel) { }
            Button("alert_delete_button_confirm".localized, role: .destructive) {
                Task { try await viewModel.UICleanProgress() }
            }
        } message: {
            Text("alert_delete_message".localized)
        }
        .padding(5)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack {
            let version = Bundle.main.releaseVersionNumber ?? "1.0"
            let build = Bundle.main.buildVersionNumber ?? "1"
            
            CardView(
                title: "NovaClean v\(version).\(build)",
                icon: "sparkles",
                color: .cardIcon
            ) {
                HStack() {
                    VStack(alignment: .leading, spacing: 4) {
                        if viewModel.isScanning {
                            HStack {
                                Text(viewModel.statusText)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(.labelSecondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle) /// long paths
                                
                                ProgressView()
                                    .foregroundStyle(.labelSecondary)
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                            }
                        } else {
                            Text(
                                String(
                                    format: "scan_summary_format".localized,
                                    viewModel.findings.count,
                                    viewModel.statusText
                                )
                            )
                            .font(.callout)
                            .foregroundColor(.labelSecondary)
                        }
                    }
                    
                    VStack {
                        IconButton(title: "button_start_scan".localized,
                                   icon: "magnifyingglass",
                                   variant: .secondary,
                                   action: { Task { await viewModel.UIScanProgress() } },
                                   isDisabled: !viewModel.hasFDA || viewModel.isScanning || viewModel.isCleaning,
                                   isLoading: viewModel.isScanning
                        )
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        .focusEffectDisabled()
                    }
                }
            }
        }
        .padding(5)
    }
    
    
    private var contentSection: some View {
        ScrollView {
            LazyVStack(spacing: 3) {
                if viewModel.showResultsScreen {
                    CleanupResultsView(
                        size: viewModel.lastCleanupSize,
                        fileCount: viewModel.lastCleanupCount,
//                        onDone: { viewModel.resetToStart() }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                } else {
                    if viewModel.findings.isEmpty && !viewModel.isScanning {
                        WelcomeView()
                            .padding(.top, 50)
                    } else {
                        ForEach($viewModel.findings) { $item in
                            if !item.isCleaned {
                                JunkRowView(item: $item)
                                    .id(item.id)
                                    .transition(
                                        .asymmetric(
                                            insertion: .opacity,
                                            removal: .opacity.combined(with: .move(edge: .leading))
                                        )
                                    )
                            }
                        }
                    }
                }
                
                
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.findings)
    }
    
    
    
    private var actionFooter: some View {
        VStack() {
            CardView(
                title: viewModel.selectedItemsSummary,
                icon: "list.dash",
                color: .cardIcon) {
                    HStack {
                        Button(action: { viewModel.UIApplySmartSelection() }) {
                            Label("button_smart_selection".localized, systemImage: "sparkles")
                                .font(.callout)
                        }
                        .disabled(viewModel.findings.isEmpty || viewModel.isScanning || viewModel.isCleaning)
                        .buttonStyle(.borderedProminent)
                        .tint(.btnSecondary.opacity(0.3))
                        .help("help_button_smart_selection".localized)
                        
                        Button(action: { viewModel.UIDeselectAll() }) {
                            Text("button_deselect_all".localized)
                                .font(.callout)
                        }
                        .disabled(viewModel.findings.isEmpty || viewModel.isScanning || viewModel.isCleaning)
                        .buttonStyle(.borderedProminent)
                        .tint(.btnSecondary.opacity(0.3))
                        
                        //                    Button(action: { viewModel.purgeMemory() }) {
                        //                        Label("Purge memory", systemImage: "memorychip")
                        //                            .font(.callout)
                        //                    }
                        //                    .disabled(viewModel.isScanning || viewModel.isCleaning)
                        //                    .buttonStyle(.bordered)
                        //                    .tint(.cyan)
                        //                    .help("It is recommended to use only when the system is highly saturated. May slightly slow down your Mac for a few moments.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        VStack {
                            Text("Developer: Arnaldo Baumanis")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.labelSecondary)
                                .frame(maxWidth: .infinity, alignment: .leadingFirstTextBaseline)
                            Text("https://github.com/arnabau")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.labelSecondary)
                                .cornerRadius(4)
                                .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
                        }
                        
                        IconButton(title: "button_clean_now".localized,
                                   icon: "trash",
                                   variant: .destructive,
                                   action: { showConfirmAlert = true },
                                   isDisabled: viewModel.totalSelectedSize == 0 || viewModel.isScanning || viewModel.isCleaning
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            
        }
        .padding(5)
    }
    
    /// FDA alert message
    private var permissionsBanner: some View {
        HStack () {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("main_view_permission_title".localized)
                    .font(.headline)
                Text("main_view_permission_description".localized)
                    .font(.callout)
            }
            
            Spacer()
            
            Button("main_view_permission_button".localized) {
                /// Open up privacy section on macOS
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct JunkRowView: View {
    @Binding var item: JunkItem
    @State private var isHovered = false
    
    private var accentColor: Color {
        item.category == .advanced || item.category.isHighRisk ? .orange : .iconList
    }
    
    var body: some View {
        
        HStack(spacing: 10) {
            // 1. Selector (Toggle)
            Toggle("", isOn: $item.isSelected)
                .toggleStyle(.checkbox)
                .labelsHidden()
                .scaleEffect(1.1)
            
            // 2. Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(accentColor.opacity(0.25), lineWidth: 1)
                    )
                    .frame(width: 42, height: 42)
                
                Image(systemName: item.category == .trash ? "trash.fill" : item.category.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
            
            // 3. Title/subtitle
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundStyle(.iconList)
                    
                    if item.category.isHighRisk {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                            .help("scan_view_help_highrisk".localized)
                    }
                }
                
                Text(String(format: "text_files".localized, item.fileCount))
                    .font(.subheadline)
                    .foregroundStyle(.labelPrimary)
            }
            
            Spacer()
            
            // 4. Action and Badge
            HStack(spacing: 15) {
                /// Warning
                if item.category.isHighRisk && item.isSelected {
                    Text("text_warning".localized)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.orange.opacity(0.2)))
                        .foregroundStyle(.orange)
                }
                
                /// Finder button
                Button(action: { revealInFinder() }) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 14))
                        .foregroundStyle(.iconList)
                }
                .buttonStyle(.plain)
                .help("button_open_folder".localized)
                
                // Value Badge
                Text(Formatters.formatBytes(item.size))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(accentColor.opacity(0.12))
                    )
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.borderList.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1)
                )
        )
        .shadow(color: .borderListShadow.opacity(isHovered ? 0.12 : 0.05), radius: isHovered ? 12 : 5, y: isHovered ? 6 : 2)
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in isHovered = hovering }
    }
    
    private func revealInFinder() {
        guard let firstPath = item.paths.first else { return }
        SystemNavigator.revealInFinder(at: firstPath.path)
    }
}

#Preview {
    ContentView()
}
