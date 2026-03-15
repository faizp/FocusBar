import Foundation

@Observable
@MainActor
final class StorageService {
    private(set) var storage: StorageInfo = .empty
    private var timer: Timer?

    init() {
        refresh()
    }

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
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
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: "/")
            let total = (attrs[.systemSize] as? Int64) ?? 0
            let free = (attrs[.systemFreeSize] as? Int64) ?? 0
            storage = StorageInfo(totalBytes: total, usedBytes: total - free, availableBytes: free)
        } catch {
            // Keep existing value
        }
    }
}
