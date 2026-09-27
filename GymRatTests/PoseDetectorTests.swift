import Testing
import UIKit
import ImageIO
import UniformTypeIdentifiers
@testable import GymRat

struct PoseDetectorTests {
    @Test func personPhotoReturns33Landmarks() throws {
        // Support/pose_person.jpg: CC0 photo by BodyBendYoga (nappy.co/photo/2432) via Wikimedia Commons.
        let url = try #require(Bundle(for: BundleToken.self).url(forResource: "pose_person", withExtension: "jpg"))
        let image = try #require(UIImage(contentsOfFile: url.path))
        let landmarks = try PoseDetector().detect(in: image)
        try #require(landmarks.count == 33)
        // MediaPipe indices: 0 nose, 23/24 hips, 27/28 ankles; y grows downward.
        #expect(landmarks[0].y < min(landmarks[23].y, landmarks[24].y))
        #expect(max(landmarks[27].y, landmarks[28].y) > max(landmarks[23].y, landmarks[24].y))
    }

    @Test func blankImageReturnsNoPerson() throws {
        #expect(try PoseDetector().detect(in: Self.blankImage()).isEmpty)
    }

    @Test func missingModelThrows() {
        #expect(throws: PoseError.self) {
            try PoseDetector(modelURL: nil).detect(in: Self.blankImage())
        }
    }

    @Test func imagePreparationAppliesEXIFRotation() async throws {
        let original = Self.blankImage(size: CGSize(width: 120, height: 80))
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try #require(original.cgImage),
                                  [kCGImagePropertyOrientation: 6] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))
        let worker = PoseAnalysisWorker(detector: PoseDetector())
        let prepared = try await worker.prepare(data as Data)
        #expect(prepared.imageOrientation == .up)
        #expect(prepared.size.width == 80)
        #expect(prepared.size.height == 120)
    }

    @Test func rotatedJPEGPreservesOrientation() async throws {
        let raw = try #require(Self.blankImage(size: CGSize(width: 120, height: 80)).cgImage)
        let rotatedImage = UIImage(cgImage: raw, scale: 1, orientation: .right)
        let data = try #require(rotatedImage.jpegData(compressionQuality: 0.9))
        let prepared = try await PoseAnalysisWorker(detector: PoseDetector()).prepare(data)
        #expect(prepared.imageOrientation == .up)
        #expect(prepared.size.width == 80)
        #expect(prepared.size.height == 120)
    }

    @MainActor @Test func emptyAndInvalidPhotoHaveDistinctStates() async throws {
        let model = PoseTestViewModel(detector: EmptyPoseDetector())
        await model.load { Self.blankImage().pngData() }
        #expect(model.messageKey == "pose_not_found")
        #expect(model.image != nil)
        #expect(!model.isBusy)
        await model.load { Data([0, 1, 2]) }
        #expect(model.messageKey == "pose_failed")
        #expect(model.image == nil)
        #expect(model.landmarks.isEmpty)
        #expect(!model.isBusy)
    }

    private static func blankImage(size: CGSize = CGSize(width: 640, height: 480)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

private struct EmptyPoseDetector: PoseDetectorType {
    func detect(in image: UIImage) throws -> [PoseLandmark] { [] }
}

private final class BundleToken {}
