import AppKit
import Foundation

@MainActor
final class IconCache {
    static let shared = IconCache()
    private var memory: [String: NSImage] = [:]
    private let diskDir: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        diskDir = appSupport.appendingPathComponent("FocusBar/IconCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskDir, withIntermediateDirectories: true)
    }

    /// Fast synchronous lookup — memory only, no I/O.
    func cachedIcon(for bundleID: String) -> NSImage? {
        memory[bundleID]
    }

    /// Full lookup: memory → disk → system. Call from .task per row.
    nonisolated func loadIcon(for bundleID: String) -> NSImage? {
        // Check disk cache (TIFF is fastest native format)
        let file = diskDir.appendingPathComponent(bundleID.replacingOccurrences(of: "/", with: "_") + ".tiff")
        if FileManager.default.fileExists(atPath: file.path),
           let image = NSImage(contentsOf: file) {
            image.size = NSSize(width: 32, height: 32)
            return image
        }

        // Resolve from system
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 32, height: 32)

        // Write to disk cache
        if let tiff = icon.tiffRepresentation {
            try? tiff.write(to: file, options: .atomic)
        }

        return icon
    }

    /// Store in memory after background load completes.
    func store(_ image: NSImage, for bundleID: String) {
        memory[bundleID] = image
    }
}
