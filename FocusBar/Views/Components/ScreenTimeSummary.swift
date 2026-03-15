import SwiftUI

struct ScreenTimeSummary: View {
    let totalSeconds: TimeInterval

    var body: some View {
        HStack {
            Image(systemName: "desktopcomputer")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Screen Time Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Formatters.duration(totalSeconds))
                    .font(.system(.title3, design: .monospaced, weight: .medium))
            }

            Spacer()
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }
}
