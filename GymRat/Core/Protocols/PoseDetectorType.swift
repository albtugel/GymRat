import UIKit

struct PoseLandmark: Sendable {
    // x/y use the image coordinate system (origin at top left). Predictions can
    // extend beyond 0...1; z is relative depth, not a normalized screen coordinate.
    let x: Float
    let y: Float
    let z: Float
    let visibility: Float?
}

protocol PoseDetectorType: Sendable {
    /// Returns one person's 33 landmarks, or an empty array if no pose is found.
    func detect(in image: UIImage) throws -> [PoseLandmark]
}
