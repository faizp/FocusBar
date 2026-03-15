import AppKit
import Foundation

@Observable
@MainActor
final class AppTrackingService {
    private(set) var todayRecords: [AppUsageRecord] = []
    private(set) var currentAppName: String?
    private(set) var currentBundleID: String?

    private var currentDateKey: String = Formatters.todayKey()
    private var lastTickTime: Date = Date()
    private var timer: Timer?
    private var workspaceObserver: NSObjectProtocol?

    init() {
        loadToday()
    }

    func start() {
        lastTickTime = Date()
        detectFrontmostApp()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
                self?.switchedTo(app: app)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            workspaceObserver = nil
        }
    }

    func save() {
        let usage = DailyUsage(date: currentDateKey, records: todayRecords)
        UsageFileManager.save(usage)
    }

    var totalScreenTime: TimeInterval {
        todayRecords.reduce(0) { $0 + $1.totalSeconds }
    }

    // MARK: - Private

    private func detectFrontmostApp() {
        guard let app = NSWorkspace.shared.frontmostApplication else { return }
        currentAppName = app.localizedName
        currentBundleID = app.bundleIdentifier
    }

    private func switchedTo(app: NSRunningApplication) {
        // Accumulate time for the previous app before switching
        accumulateElapsed()

        currentAppName = app.localizedName
        currentBundleID = app.bundleIdentifier
        lastTickTime = Date()
    }

    private func tick() {
        checkDayRollover()
        accumulateElapsed()
    }

    private func accumulateElapsed() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTickTime)
        lastTickTime = now

        guard let appName = currentAppName, elapsed > 0, elapsed < 10 else { return }

        if let index = todayRecords.firstIndex(where: { $0.appName == appName }) {
            todayRecords[index].totalSeconds += elapsed

            // Cache icon if missing
            if todayRecords[index].iconData == nil {
                todayRecords[index].iconData = iconData(for: currentBundleID)
            }
        } else {
            let record = AppUsageRecord(
                appName: appName,
                bundleID: currentBundleID,
                totalSeconds: elapsed,
                iconData: iconData(for: currentBundleID)
            )
            todayRecords.append(record)
        }

        // Auto-save every 30 seconds
        if Int(todayRecords.reduce(0, { $0 + $1.totalSeconds })) % 30 == 0 {
            save()
        }
    }

    private func checkDayRollover() {
        let today = Formatters.todayKey()
        if today != currentDateKey {
            save()
            currentDateKey = today
            todayRecords = []
        }
    }

    private func loadToday() {
        currentDateKey = Formatters.todayKey()
        if let usage = UsageFileManager.load(for: currentDateKey) {
            todayRecords = usage.records
        }
    }

    private func iconData(for bundleID: String?) -> Data? {
        guard let bundleID,
              let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID),
              let bundle = Bundle(url: url) else { return nil }

        let icon = NSWorkspace.shared.icon(forFile: bundle.bundlePath)
        let size = NSSize(width: 32, height: 32)
        icon.size = size

        guard let tiffData = icon.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return nil }
        return pngData
    }
}
