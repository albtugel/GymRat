import ImageIO
import Observation
import UIKit

/// Decoding and inference both run away from the main actor. The same upright,
/// bounded-size image is displayed and analyzed, including EXIF-rotated photos.
actor PoseAnalysisWorker {
    private let detector: any PoseDetectorType

    init(detector: any PoseDetectorType) { self.detector = detector }

    func prepare(_ data: Data) throws -> UIImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 2048
              ] as CFDictionary) else { throw PoseError.invalidImage }
        return UIImage(cgImage: cgImage)
    }

    func detect(_ image: UIImage) throws -> [PoseLandmark] {
        try detector.detect(in: image)
    }
}

@MainActor @Observable
final class PoseTestViewModel {
    private(set) var image: UIImage?
    private(set) var landmarks: [PoseLandmark] = []
    private(set) var isBusy = false
    private(set) var messageKey = "pose_intro"
    private let worker: PoseAnalysisWorker
    private var requestID = UUID()

    init(detector: any PoseDetectorType) {
        worker = PoseAnalysisWorker(detector: detector)
    }

    func load(_ loader: () async throws -> Data?) async {
        let id = UUID()
        requestID = id
        isBusy = true
        image = nil
        landmarks = []
        messageKey = "pose_loading"
        defer { if requestID == id { isBusy = false } }
        do {
            guard let data = try await loader() else { throw PoseError.invalidImage }
            let prepared = try await worker.prepare(data)
            guard requestID == id, !Task.isCancelled else { return }
            image = prepared
            messageKey = "pose_analyzing"
            let result = try await worker.detect(prepared)
            guard requestID == id, !Task.isCancelled else { return }
            landmarks = result
            messageKey = result.isEmpty ? "pose_not_found" : "pose_found"
        } catch {
            guard requestID == id, !Task.isCancelled else { return }
            messageKey = error is PoseError && (error as? PoseError) == .modelMissing
                ? "pose_model_missing" : "pose_failed"
        }
    }
}
