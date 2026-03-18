import SwiftUI

@main
struct FocusBarApp: App {
    @State private var uptimeService = UptimeService()
    @State private var appTrackingService = AppTrackingService()
    @State private var resourceMonitorService = ResourceMonitorService()
    @State private var storageService = StorageService()
    @State private var categoryManager = CategoryManager()
    @State private var todoService = TodoService()

    var body: some Scene {
        MenuBarExtra("FocusBar", systemImage: "chart.bar.fill") {
            PopoverView()
                .environment(uptimeService)
                .environment(appTrackingService)
                .environment(resourceMonitorService)
                .environment(storageService)
                .environment(categoryManager)
                .environment(todoService)
                .onAppear {
                    startServices()
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(categoryManager)
                .environment(appTrackingService)
        }
    }

    init() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [self] _ in
            Task { @MainActor in
                appTrackingService.save()
            }
        }
    }

    @MainActor
    private func startServices() {
        uptimeService.start()
        appTrackingService.start()
        resourceMonitorService.start()
        storageService.start()
    }
}
