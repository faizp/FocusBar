import SwiftUI

struct StorageBarView: View {
    let storage: StorageInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(barColor)
                        .frame(width: geo.size.width * storage.usedFraction)
                }
            }
            .frame(height: 20)

            HStack {
                Text("\(Formatters.gb(storage.usedGB)) used")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Formatters.gb(storage.availableGB)) available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var barColor: Color {
        if storage.usedFraction > 0.9 { return .red }
        if storage.usedFraction > 0.75 { return .orange }
        return .blue
    }
}
