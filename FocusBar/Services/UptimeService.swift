import AppKit
import Foundation

@Observable
@MainActor
final class UptimeService {
    private(set) var awakeUptime: TimeInterval = 0
    private(set) var bootUptime: TimeInterval = 0
    private var timer: Timer?
    private var sleepStart: Date?
    private var totalSleepSeconds: TimeInterval = 0
    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?

    init() {
        bootUptime = timeSinceBoot()
        awakeUptime = bootUptime
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        sleepObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.sleepStart = Date()
            }
        }

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, let start = self.sleepStart else { return }
                self.totalSleepSeconds += Date().timeIntervalSince(start)
                self.sleepStart = nil
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let o = sleepObserver { NSWorkspace.shared.notificationCenter.removeObserver(o) }
        if let o = wakeObserver { NSWorkspace.shared.notificationCenter.removeObserver(o) }
    }

    private func tick() {
        bootUptime = timeSinceBoot()
        awakeUptime = bootUptime - totalSleepSeconds
    }

    /// Wall-clock time since boot via kern.boottime sysctl.
    private func timeSinceBoot() -> TimeInterval {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.size
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        guard sysctl(&mib, 2, &boottime, &size, nil, 0) == 0 else {
            return ProcessInfo.processInfo.systemUptime
        }
        let bootDate = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec) / 1_000_000)
        return Date().timeIntervalSince(bootDate)
    }
}
