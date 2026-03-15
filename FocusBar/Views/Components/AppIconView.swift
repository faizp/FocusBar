import SwiftUI

struct AppIconView: View {
    var iconData: Data?
    var bundleID: String?
    var size: CGFloat = 24

    @State private var loadedImage: NSImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let image = loadedImage ?? memoryHit {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
            } else if isLoading {
                RoundedRectangle(cornerRadius: size * 0.2)
                    .fill(.quaternary)
                    .frame(width: size, height: size)
                    .overlay {
                        ProgressView()
                            .scaleEffect(size > 20 ? 0.5 : 0.4)
                    }
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: bundleID) {
            guard loadedImage == nil, memoryHit == nil else { return }

            if let iconData, let img = NSImage(data: iconData) {
                loadedImage = img
                return
            }

            guard let bid = bundleID else { return }
            isLoading = true
            let img = await Task.detached { IconCache.shared.loadIcon(for: bid) }.value
            if let img {
                loadedImage = img
                await MainActor.run { IconCache.shared.store(img, for: bid) }
            }
            isLoading = false
        }
    }

    private var memoryHit: NSImage? {
        guard let bundleID else { return nil }
        return IconCache.shared.cachedIcon(for: bundleID)
    }
}
