import MediaPipeTasksVision
import UIKit

enum PoseError: Error {
    case modelMissing, invalidImage, invalidResult
}

/// The lock protects lazy initialization and the non-thread-safe MediaPipe task.
/// Inference is synchronous; callers must use a background executor.
final class PoseDetector: PoseDetectorType, @unchecked Sendable {
    private let lock = NSLock()
    private let modelURL: URL?
    private var landmarker: PoseLandmarker?

    init(modelURL: URL? = Bundle.main.url(forResource: "pose_landmarker_lite", withExtension: "task")) {
        self.modelURL = modelURL
    }

    func detect(in image: UIImage) throws -> [PoseLandmark] {
        lock.lock()
        defer { lock.unlock() }
        if landmarker == nil {
            guard let modelURL else { throw PoseError.modelMissing }
            let options = PoseLandmarkerOptions()
            options.baseOptions.modelAssetPath = modelURL.path
            options.runningMode = .image
            options.numPoses = 1
            landmarker = try PoseLandmarker(options: options)
        }
        guard let landmarker else { throw PoseError.modelMissing }
        let result = try landmarker.detect(image: MPImage(uiImage: image))
        guard let landmarks = result.landmarks.first else { return [] }
        guard landmarks.count == 33 else { throw PoseError.invalidResult }
        return landmarks.map {
            PoseLandmark(x: $0.x, y: $0.y, z: $0.z, visibility: $0.visibility?.floatValue)
        }
    }
}
