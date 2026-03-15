import AppKit
import Darwin
import Foundation

@Observable
@MainActor
final class ResourceMonitorService {
    private(set) var runningApps: [RunningAppInfo] = []
    private(set) var totalCPU: Double = 0
    private(set) var totalMemoryMB: Double = 0
    private var timer: Timer?
    private var previousCPUTimes: [pid_t: (user: UInt64, system: UInt64, timestamp: Date)] = [:]

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications.filter {
            $0.activationPolicy == .regular || $0.activationPolicy == .accessory
        }

        var infos: [RunningAppInfo] = []
        var newPreviousTimes: [pid_t: (user: UInt64, system: UInt64, timestamp: Date)] = [:]

        for app in apps {
            let pid = app.processIdentifier
            guard pid > 0 else { continue }

            var taskInfo = proc_taskinfo()
            let size = MemoryLayout<proc_taskinfo>.size
            let result = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, Int32(size))

            if result == Int32(size) {
                let memoryMB = Double(taskInfo.pti_resident_size) / 1_048_576

                // CPU delta calculation
                let now = Date()
                let currentUser = taskInfo.pti_total_user
                let currentSystem = taskInfo.pti_total_system

                var cpuPercent: Double = 0

                if let previous = previousCPUTimes[pid] {
                    let elapsed = now.timeIntervalSince(previous.timestamp)
                    if elapsed > 0 {
                        let userDelta = Double(currentUser - previous.user) / 1_000_000_000 // ns to s
                        let systemDelta = Double(currentSystem - previous.system) / 1_000_000_000
                        cpuPercent = ((userDelta + systemDelta) / elapsed) * 100
                    }
                }

                newPreviousTimes[pid] = (user: currentUser, system: currentSystem, timestamp: now)

                let info = RunningAppInfo(
                    pid: pid,
                    name: app.localizedName ?? "Unknown",
                    bundleID: app.bundleIdentifier,
                    cpuPercent: cpuPercent,
                    memoryMB: memoryMB
                )
                infos.append(info)
            }
        }

        previousCPUTimes = newPreviousTimes
        runningApps = infos.sorted { $0.cpuPercent > $1.cpuPercent }
        totalCPU = infos.reduce(0) { $0 + $1.cpuPercent }
        totalMemoryMB = infos.reduce(0) { $0 + $1.memoryMB }
    }
}
