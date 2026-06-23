import Foundation

enum Settings {
    enum Keys {
        static let theme = "peeky.theme"
        static let fontSize = "peeky.fontSize"
        static let lineWidth = "peeky.lineWidth"
    }

    enum Theme: String {
        case system, light, dark
    }

    static var theme: Theme {
        let raw = UserDefaults.standard.string(forKey: Keys.theme) ?? Theme.system.rawValue
        return Theme(rawValue: raw) ?? .system
    }

    static var fontSize: Int {
        let v = UserDefaults.standard.double(forKey: Keys.fontSize)
        return v > 0 ? Int(v) : 16
    }

    static var lineWidth: Int {
        let v = UserDefaults.standard.double(forKey: Keys.lineWidth)
        return v > 0 ? Int(v) : 720
    }
}
