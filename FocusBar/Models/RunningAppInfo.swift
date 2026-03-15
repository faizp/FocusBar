import Foundation

struct RunningAppInfo: Identifiable {
    let pid: pid_t
    let name: String
    let bundleID: String?
    var cpuPercent: Double
    var memoryMB: Double

    var id: pid_t { pid }
}
