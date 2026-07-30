import Foundation
import Kingfisher

/// Warms the image cache for the exercises of the day currently on screen, so opening the details
/// sheet renders the GIF straight away instead of showing a spinner.
///
/// `ImagePrefetcher` skips resources that are already cached, so repeat calls for the same day cost
/// no network traffic.
@MainActor
final class ExerciseImagePrefetcher {
    private var running: ImagePrefetcher?

    func prefetch(exerciseNames: [String]) {
        guard !exerciseNames.isEmpty else { return }

        Task { [weak self] in
            let urls = await ExerciseRepo.shared.gifURLs(forExerciseNames: exerciseNames)
            guard let self, !urls.isEmpty else { return }
            self.start(urls: urls)
        }
    }

    func cancel() {
        running?.stop()
        running = nil
    }

    private func start(urls: [URL]) {
        // Switching days makes the previous day's warm-up pointless; drop it before starting over.
        running?.stop()
        let prefetcher = ImagePrefetcher(urls: urls)
        running = prefetcher
        prefetcher.start()
    }
}
