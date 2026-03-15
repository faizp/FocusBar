import SwiftUI

struct TopAppsSection: View {
    let records: [AppUsageRecord]
    var limit: Int = 5

    private var topRecords: [AppUsageRecord] {
        Array(records.sorted { $0.totalSeconds > $1.totalSeconds }.prefix(limit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Top Apps")
                .font(.headline)

            if topRecords.isEmpty {
                Text("No apps tracked yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(topRecords) { record in
                    HStack(spacing: 8) {
                        AppIconView(iconData: record.iconData, size: 20)

                        Text(record.appName)
                            .font(.callout)
                            .lineLimit(1)

                        Spacer()

                        Text(Formatters.shortDuration(record.totalSeconds))
                            .font(.system(.callout, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
