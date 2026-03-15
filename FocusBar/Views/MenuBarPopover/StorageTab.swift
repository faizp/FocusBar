import SwiftUI

struct StorageTab: View {
    @Environment(StorageService.self) private var storageService

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Disk Storage")
                        .font(.headline)

                    StorageBarView(storage: storageService.storage)
                }

                Divider()

                VStack(spacing: 8) {
                    StorageDetailRow(
                        label: "Total Capacity",
                        value: Formatters.gb(storageService.storage.totalGB),
                        icon: "internaldrive"
                    )
                    StorageDetailRow(
                        label: "Used",
                        value: Formatters.gb(storageService.storage.usedGB),
                        icon: "chart.bar.fill"
                    )
                    StorageDetailRow(
                        label: "Available",
                        value: Formatters.gb(storageService.storage.availableGB),
                        icon: "externaldrive"
                    )
                    StorageDetailRow(
                        label: "Usage",
                        value: Formatters.percent(storageService.storage.usedFraction * 100),
                        icon: "percent"
                    )
                }
            }
            .padding()
        }
    }
}
