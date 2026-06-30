import Foundation

enum AppSettings {
    enum Keys {
        static let theme = "peeky.theme"
        static let fontSize = "peeky.fontSize"
        static let lineWidth = "peeky.lineWidth"
        static let isActive = "peeky.active"
    }

    enum Theme: String {
        case system, light, dark
    }

    /// Shared UserDefaults suite — syncs settings between app container and Quick Look extension.
    /// Falls back to .standard if the App Group entitlement is not provisioned (dev without signing).
    static let store: UserDefaults = UserDefaults(suiteName: "group.com.peeky") ?? .standard

    static var theme: Theme {
        let raw = store.string(forKey: Keys.theme) ?? Theme.system.rawValue
        return Theme(rawValue: raw) ?? .system
    }

    static var fontSize: Int {
        let v = store.double(forKey: Keys.fontSize)
        return v > 0 ? Int(v) : 16
    }

    static var lineWidth: Int {
        let v = store.double(forKey: Keys.lineWidth)
        return v > 0 ? Int(v) : 720
    }

    static var isActive: Bool {
        get { store.bool(forKey: Keys.isActive) }
        set { store.set(newValue, forKey: Keys.isActive) }
    }
}
