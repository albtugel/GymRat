import Foundation

/// Values injected through `Secrets.xcconfig` into Info.plist.
///
/// A missing or empty value is `nil`, not a crash: a checkout without the xcconfig must still build
/// and run, and the feature that needs a key decides how to fail (`WorkoutXClient` throws
/// `missingAPIKey` for an empty key).
enum Secrets {
    /// Unused until `WorkoutXClient` is adopted; see that type's documentation.
    static var workoutXAPIKey: String? {
        value(for: "WORKOUTX_API_KEY")
    }

    private static func value(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            return nil
        }
        return value
    }
}
