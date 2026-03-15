import SwiftUI

struct UptimeCard: View {
    let uptime: TimeInterval

    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("System Uptime")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Formatters.duration(uptime))
                    .font(.system(.title3, design: .monospaced, weight: .medium))
            }

            Spacer()
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }
}
