import Foundation
import os

/// Loggers used across the app.
///
/// `os.Logger` replaces `print` so diagnostics stay out of release builds by default while remaining
/// readable in Console.app and `log stream` during development. Use `debug` for chatty per-item
/// tracing and `notice` for state worth seeing in a shipped build.
enum AppLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "AL.GymRat"

    static let exerciseRepo = Logger(subsystem: subsystem, category: "ExerciseRepo")
    static let imageCache = Logger(subsystem: subsystem, category: "ImageCache")
}
