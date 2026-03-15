import SwiftUI

struct CategorySlice: Identifiable {
    let id = UUID()
    let category: AppCategory
    let seconds: TimeInterval
    var fraction: Double = 0
}

struct CategoryBreakdownChart: View {
    let records: [AppUsageRecord]
    let categoryManager: CategoryManager

    private var slices: [CategorySlice] {
        var totals: [AppCategory: TimeInterval] = [:]
        for record in records {
            let cat = categoryManager.category(for: record.bundleID)
            totals[cat, default: 0] += record.totalSeconds
        }
        let total = totals.values.reduce(0, +)
        return totals.map {
            CategorySlice(
                category: $0.key,
                seconds: $0.value,
                fraction: total > 0 ? $0.value / total : 0
            )
        }
        .sorted { $0.seconds > $1.seconds }
    }

    var body: some View {
        if slices.isEmpty {
            Text("No data yet")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(height: 40)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Category Breakdown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Stacked horizontal bar
                GeometryReader { geo in
                    HStack(spacing: 1.5) {
                        ForEach(slices) { slice in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(color(for: slice.category))
                                .frame(width: max(4, geo.size.width * slice.fraction - 1.5))
                        }
                    }
                }
                .frame(height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 4))

                // Legend
                FlowLayout(spacing: 4) {
                    ForEach(slices) { slice in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(color(for: slice.category))
                                .frame(width: 7, height: 7)
                            Text("\(slice.category.displayName) \(Int(slice.fraction * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func color(for category: AppCategory) -> Color {
        switch category {
        case .productivity: .blue
        case .development: .purple
        case .communication: .green
        case .entertainment: .orange
        case .utilities: .gray
        case .browsers: .cyan
        case .other: .secondary
        }
    }
}

// Simple flow layout for legend items
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing * 2
            maxWidth = max(maxWidth, x)
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
