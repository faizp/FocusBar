import Foundation

enum UsageFileManager {
    private static var directory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("FocusBar", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func fileURL(for dateKey: String) -> URL {
        directory.appendingPathComponent("usage_\(dateKey).json")
    }

    static func load(for dateKey: String) -> DailyUsage? {
        let url = fileURL(for: dateKey)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(DailyUsage.self, from: data)
    }

    static func save(_ usage: DailyUsage) {
        let url = fileURL(for: usage.date)
        guard let data = try? JSONEncoder().encode(usage) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Category Overrides

    private static var categoryOverridesURL: URL {
        directory.appendingPathComponent("category_overrides.json")
    }

    static func loadCategoryOverrides() -> [String: AppCategory] {
        guard let data = try? Data(contentsOf: categoryOverridesURL) else { return [:] }
        return (try? JSONDecoder().decode([String: AppCategory].self, from: data)) ?? [:]
    }

    static func saveCategoryOverrides(_ overrides: [String: AppCategory]) {
        guard let data = try? JSONEncoder().encode(overrides) else { return }
        try? data.write(to: categoryOverridesURL, options: .atomic)
    }
}
