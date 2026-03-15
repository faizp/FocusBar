import SwiftUI

struct OverviewTab: View {
    @Environment(UptimeService.self) private var uptimeService
    @Environment(AppTrackingService.self) private var appTracking
    @Environment(CategoryManager.self) private var categoryManager

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Compact stats header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Uptime")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(Formatters.duration(uptimeService.awakeUptime))
                                .font(.system(.callout, design: .monospaced, weight: .medium))
                        }
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "desktopcomputer")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("Screen Time")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(Formatters.duration(appTracking.totalScreenTime))
                                .font(.system(.callout, design: .monospaced, weight: .medium))
                        }
                    }
                }
                .padding(10)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))

                // Category breakdown bar
                CategoryBreakdownChart(
                    records: appTracking.todayRecords,
                    categoryManager: categoryManager
                )

                Divider()

                // Top apps
                TopAppsSection(records: appTracking.todayRecords)
            }
            .padding()
        }
    }
}
