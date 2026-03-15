import Foundation

enum AppCategory: String, Codable, CaseIterable, Identifiable {
    case productivity
    case development
    case communication
    case entertainment
    case utilities
    case browsers
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .productivity: "Productivity"
        case .development: "Development"
        case .communication: "Communication"
        case .entertainment: "Entertainment"
        case .utilities: "Utilities"
        case .browsers: "Browsers"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .productivity: "doc.text"
        case .development: "chevron.left.forwardslash.chevron.right"
        case .communication: "bubble.left.and.bubble.right"
        case .entertainment: "play.circle"
        case .utilities: "gearshape"
        case .browsers: "globe"
        case .other: "square.grid.2x2"
        }
    }

    var color: String {
        switch self {
        case .productivity: "blue"
        case .development: "purple"
        case .communication: "green"
        case .entertainment: "orange"
        case .utilities: "gray"
        case .browsers: "cyan"
        case .other: "secondary"
        }
    }

    static let defaultMappings: [String: AppCategory] = [
        // Productivity
        "com.apple.Pages": .productivity,
        "com.apple.Numbers": .productivity,
        "com.apple.Keynote": .productivity,
        "com.microsoft.Word": .productivity,
        "com.microsoft.Excel": .productivity,
        "com.microsoft.PowerPoint": .productivity,
        "com.apple.iWork.Pages": .productivity,
        "com.apple.iWork.Numbers": .productivity,
        "com.apple.iWork.Keynote": .productivity,
        "com.notion.id": .productivity,
        "com.linear": .productivity,

        // Development
        "com.apple.dt.Xcode": .development,
        "com.microsoft.VSCode": .development,
        "com.visualstudio.code.oss": .development,
        "com.sublimetext.4": .development,
        "com.googlecode.iterm2": .development,
        "com.apple.Terminal": .development,
        "com.jetbrains.intellij": .development,
        "dev.warp.Warp-Stable": .development,
        "com.todesktop.230313mzl4w4u92": .development, // Cursor

        // Communication
        "com.apple.MobileSMS": .communication,
        "com.apple.mail": .communication,
        "com.tinyspeck.slackmacgap": .communication,
        "com.microsoft.teams2": .communication,
        "us.zoom.xos": .communication,
        "com.hnc.Discord": .communication,
        "ru.keepcoder.Telegram": .communication,
        "net.whatsapp.WhatsApp": .communication,
        "com.facebook.archon.developerID": .communication,

        // Entertainment
        "com.spotify.client": .entertainment,
        "com.apple.Music": .entertainment,
        "com.apple.TV": .entertainment,
        "com.google.Chrome.app.YouTube": .entertainment,
        "com.netflix.Netflix": .entertainment,

        // Browsers
        "com.apple.Safari": .browsers,
        "com.google.Chrome": .browsers,
        "com.mozilla.firefox": .browsers,
        "com.brave.Browser": .browsers,
        "company.thebrowser.Browser": .browsers, // Arc

        // Utilities
        "com.apple.finder": .utilities,
        "com.apple.systempreferences": .utilities,
        "com.apple.ActivityMonitor": .utilities,
        "com.apple.Preview": .utilities,
        "com.apple.calculator": .utilities,
    ]
}
