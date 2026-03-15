import SwiftUI

enum PopoverTab: String, CaseIterable {
    case overview = "Overview"
    case appUsage = "Apps"
    case running = "Running"
    case storage = "Storage"

    var icon: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .appUsage: "clock"
        case .running: "cpu"
        case .storage: "internaldrive"
        }
    }
}

struct PopoverView: View {
    @Environment(\.openSettings) private var openSettings
    @State private var selectedTab: PopoverTab = .overview

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("", selection: $selectedTab) {
                ForEach(PopoverTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Tab content
            Group {
                switch selectedTab {
                case .overview:
                    OverviewTab()
                case .appUsage:
                    AppUsageTab()
                case .running:
                    RunningAppsTab()
                case .storage:
                    StorageTab()
                }
            }
            .frame(maxHeight: .infinity)

            Divider()

            // Footer
            HStack {
                Button {
                    openSettings()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApp.activate(ignoringOtherApps: true)
                        for window in NSApp.windows where window.title.contains("Settings") || window.identifier?.rawValue.contains("settings") == true {
                            window.makeKeyAndOrderFront(nil)
                            window.level = .floating
                            // Reset to normal after it's visible so it behaves normally
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                window.level = .normal
                            }
                        }
                    }
                } label: {
                    Label("Settings", systemImage: "gear")
                        .font(.caption)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 360, height: 480)
    }
}
