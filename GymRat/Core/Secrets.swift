import Foundation

enum Secrets {
    static let rapidAPIKey = value(for: "RAPID_API_KEY")
    static let rapidAPIHost = value(for: "RAPID_API_HOST")
    static let workoutXAPIKey = value(for: "WORKOUTX_API_KEY")

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            fatalError("Missing value for \(key) in Info.plist")
        }
        return value
    }
}
