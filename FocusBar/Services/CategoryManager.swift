import Foundation

@Observable
@MainActor
final class CategoryManager {
    private(set) var overrides: [String: AppCategory] = [:]

    init() {
        overrides = UsageFileManager.loadCategoryOverrides()
    }

    func category(for bundleID: String?) -> AppCategory {
        guard let bundleID else { return .other }
        if let override = overrides[bundleID] {
            return override
        }
        return AppCategory.defaultMappings[bundleID] ?? .other
    }

    func setCategory(_ category: AppCategory, for bundleID: String) {
        overrides[bundleID] = category
        UsageFileManager.saveCategoryOverrides(overrides)
    }

    func removeOverride(for bundleID: String) {
        overrides.removeValue(forKey: bundleID)
        UsageFileManager.saveCategoryOverrides(overrides)
    }
}
