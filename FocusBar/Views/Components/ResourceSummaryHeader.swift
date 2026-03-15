import SwiftUI

struct ResourceSummaryHeader: View {
    let totalCPU: Double
    let totalMemoryMB: Double

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text("CPU")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(Formatters.cpuPercent(totalCPU))
                    .font(.system(.title3, design: .monospaced, weight: .medium))
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 30)

            VStack(spacing: 2) {
                Text("Memory")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(Formatters.memoryMB(totalMemoryMB))
                    .font(.system(.title3, design: .monospaced, weight: .medium))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }
}
