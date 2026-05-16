import Foundation

extension ExerciseRepo {
    static var cacheFileName: String {
        "exercisedb-exercises-cache.json"
    }

    static func cacheURL(fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let appDirectory = directory.appendingPathComponent("GymRat", isDirectory: true)
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        return appDirectory.appendingPathComponent(fileName)
    }

    static func saveCachedRemoteExercises(_ exercises: [RemoteExercise], fileName: String) {
        guard let url = cacheURL(fileName: fileName) else { return }
        do {
            let data = try JSONEncoder().encode(exercises)
            try data.write(to: url, options: [.atomic])
            log("Saved API cache to \(url.path).")
        } catch {
            log("Failed to save cache: \(error.localizedDescription)")
        }
    }

    static func loadCachedRemoteExercises(fileName: String) -> [RemoteExercise]? {
        guard let url = cacheURL(fileName: fileName) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([RemoteExercise].self, from: data)
        } catch {
            log("Failed to read cache: \(error.localizedDescription)")
            return nil
        }
    }
}
