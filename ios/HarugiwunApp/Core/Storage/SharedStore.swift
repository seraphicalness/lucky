import Foundation

struct SharedStore {
    static let appGroupID = "group.com.example.harugiwun"

    static func saveWidgetFortune(_ fortune: FortuneWidgetResponse) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(fortune) else { return }
        defaults.set(data, forKey: "widget_fortune")
    }

    static func loadWidgetFortune() -> FortuneWidgetResponse? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "widget_fortune") else { return nil }
        return try? JSONDecoder().decode(FortuneWidgetResponse.self, from: data)
    }
}
