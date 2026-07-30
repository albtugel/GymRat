import Foundation

enum Secrets {
    static let workoutXAPIKey = value(for: "WORKOUTX_API_KEY")

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            fatalError("Missing value for \(key) in Info.plist")
        }
        return value
    }
}
