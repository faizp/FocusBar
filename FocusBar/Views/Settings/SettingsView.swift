import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            CategorySettingsView()
                .tabItem {
                    Label("Categories", systemImage: "tag")
                }
        }
        .frame(width: 450, height: 350)
    }
}
