import SwiftUI

struct RunningAppsTab: View {
    @Environment(ResourceMonitorService.self) private var resourceMonitor

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ResourceSummaryHeader(
                    totalCPU: resourceMonitor.totalCPU,
                    totalMemoryMB: resourceMonitor.totalMemoryMB
                )
                .padding()

                if resourceMonitor.runningApps.isEmpty {
                    Text("No running apps detected")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("App")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("CPU")
                                .frame(width: 60, alignment: .trailing)
                            Text("Memory")
                                .frame(width: 70, alignment: .trailing)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 4)

                        ForEach(resourceMonitor.runningApps) { app in
                            appRow(app)
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }

    private func appRow(_ app: RunningAppInfo) -> some View {
        HStack {
            Text(app.name)
                .font(.callout)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(Formatters.cpuPercent(app.cpuPercent))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(app.cpuPercent > 50 ? .red : .secondary)
                .frame(width: 60, alignment: .trailing)

            Text(Formatters.memoryMB(app.memoryMB))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
