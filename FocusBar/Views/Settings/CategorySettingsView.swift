import AppKit
import SwiftUI

struct CategorizedApp: Identifiable, Sendable {
    let id: String // bundleID
    let name: String
}

struct CategorySettingsView: View {
    @Environment(CategoryManager.self) private var categoryManager
    @Environment(AppTrackingService.self) private var appTracking
    @State private var allApps: [CategorizedApp] = []
    @State private var searchText = ""

    private var filteredApps: [CategorizedApp] {
        if searchText.isEmpty { return allApps }
        return allApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()

            List(filteredApps) { app in
                HStack {
                    AppIconView(bundleID: app.id, size: 20)
                    Text(app.name)
                        .font(.callout)
                        .lineLimit(1)

                    Spacer()

                    Picker("", selection: Binding(
                        get: { categoryManager.category(for: app.id) },
                        set: { categoryManager.setCategory($0, for: app.id) }
                    )) {
                        ForEach(AppCategory.allCases) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    .frame(width: 140)
                }
            }
        }
        .task { await loadAllApps() }
    }

    private func loadAllApps() async {
        var seen = Set<String>()
        var apps: [CategorizedApp] = []

        // 1. Running GUI apps — instant, no I/O
        for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
            if let bid = app.bundleIdentifier, seen.insert(bid).inserted {
                apps.append(CategorizedApp(id: bid, name: app.localizedName ?? bid))
            }
        }

        // 2. Today's tracked apps — instant, in memory
        for record in appTracking.todayRecords {
            if let bid = record.bundleID, seen.insert(bid).inserted {
                apps.append(CategorizedApp(id: bid, name: record.appName))
            }
        }

        // Show running + tracked immediately
        allApps = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        // 3. Resolve default mappings in background
        let bidsToResolve = AppCategory.defaultMappings.keys.filter { seen.insert($0).inserted }
        if !bidsToResolve.isEmpty {
            let resolved = await Task.detached {
                bidsToResolve.compactMap { bid -> CategorizedApp? in
                    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid),
                          let bundle = Bundle(url: url) else { return nil }
                    let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                        ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                        ?? url.deletingPathExtension().lastPathComponent
                    return CategorizedApp(id: bid, name: name)
                }
            }.value

            apps.append(contentsOf: resolved)
            allApps = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
}
