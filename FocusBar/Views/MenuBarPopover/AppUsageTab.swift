import SwiftUI

struct AppUsageTab: View {
    @Environment(AppTrackingService.self) private var appTracking
    @Environment(CategoryManager.self) private var categoryManager

    private var sortedRecords: [AppUsageRecord] {
        appTracking.todayRecords.sorted { $0.totalSeconds > $1.totalSeconds }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("Today's App Usage")
                        .font(.headline)
                    Spacer()
                    Text(Formatters.shortDuration(appTracking.totalScreenTime))
                        .font(.system(.callout, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding()

                if sortedRecords.isEmpty {
                    Text("No apps tracked yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedRecords) { record in
                            appRow(record)
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }

    private func appRow(_ record: AppUsageRecord) -> some View {
        HStack(spacing: 10) {
            AppIconView(iconData: record.iconData, size: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.appName)
                    .font(.callout)
                    .lineLimit(1)

                let cat = categoryManager.category(for: record.bundleID)
                Text(cat.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(Formatters.shortDuration(record.totalSeconds))
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
