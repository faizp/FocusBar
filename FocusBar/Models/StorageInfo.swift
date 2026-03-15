import Foundation

struct StorageInfo {
    let totalBytes: Int64
    let usedBytes: Int64
    let availableBytes: Int64

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var totalGB: Double { Double(totalBytes) / 1_073_741_824 }
    var usedGB: Double { Double(usedBytes) / 1_073_741_824 }
    var availableGB: Double { Double(availableBytes) / 1_073_741_824 }

    static let empty = StorageInfo(totalBytes: 0, usedBytes: 0, availableBytes: 0)
}
