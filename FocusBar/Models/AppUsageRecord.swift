import Foundation

struct AppUsageRecord: Codable, Identifiable {
    var id: String { bundleID ?? appName }
    let appName: String
    let bundleID: String?
    var totalSeconds: TimeInterval
    var iconData: Data?

    init(appName: String, bundleID: String?, totalSeconds: TimeInterval = 0, iconData: Data? = nil) {
        self.appName = appName
        self.bundleID = bundleID
        self.totalSeconds = totalSeconds
        self.iconData = iconData
    }
}

struct DailyUsage: Codable {
    let date: String // yyyy-MM-dd
    var records: [AppUsageRecord]
}
