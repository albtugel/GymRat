import AVFoundation
import PhotosUI
import SwiftUI

struct PoseTestView: View {
    @State var viewModel: PoseTestViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showCamera = false
    @State private var cameraAvailable = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    if let image = viewModel.image {
                        photoPreview(image, availableSize: geometry.size)
                    } else {
                        ContentUnavailableView("pose_choose_photo", systemImage: "figure.stand",
                                               description: Text("pose_photo_hint"))
                            .frame(minHeight: geometry.size.height * 0.45)
                    }

                    if viewModel.isBusy { ProgressView() }
                    Text(LocalizedStringKey(viewModel.messageKey))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("poseStatus")

                    Text("pose_privacy_note")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("pose_choose_photo", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("posePhotoPicker")
                    .disabled(viewModel.isBusy)

                    Button {
                        showCamera = true
                    } label: {
                        Label("pose_take_photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("poseCameraButton")
                    .disabled(viewModel.isBusy || !cameraAvailable)
                }
                .controlSize(.large)

                if !cameraAvailable {
                    Text("pose_camera_unavailable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
        .navigationTitle("pose_title")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: updateCameraAvailability)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { updateCameraAvailability() }
        }
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            await viewModel.load { try await selectedPhoto.loadTransferable(type: Data.self) }
        }
        .sheet(isPresented: $showCamera, onDismiss: updateCameraAvailability) {
            PoseCameraPicker { image in
                Task {
                    await viewModel.load {
                        await Task.detached(priority: .userInitiated) {
                            image.jpegData(compressionQuality: 0.9)
                        }.value
                    }
                }
            }
        }
    }

    private func updateCameraAvailability() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
            && AVCaptureDevice.default(for: .video) != nil
            && status != .denied && status != .restricted
    }

    private func photoPreview(_ image: UIImage, availableSize: CGSize) -> some View {
        let width = max(1, availableSize.width - 32)
        let maxHeight = max(1, availableSize.height * 0.55)
        let height = min(width * image.size.height / image.size.width, maxHeight)
        let fittedWidth = height * image.size.width / image.size.height

        return Image(uiImage: image)
            .resizable()
            .frame(width: fittedWidth, height: height)
            .overlay { PoseSkeletonOverlay(landmarks: viewModel.landmarks) }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
    }
}

private struct PoseCameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onPhoto: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: PoseCameraPicker

        init(_ parent: PoseCameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onPhoto(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PoseSkeletonOverlay: View {
    let landmarks: [PoseLandmark]

    // MediaPipe's 33-landmark topology (left and right refer to the person).
    private static let connections: [(Int, Int)] = [
        (0,1), (1,2), (2,3), (3,7), (0,4), (4,5), (5,6), (6,8), (9,10),
        (11,12), (11,13), (13,15), (15,17), (15,19), (15,21), (17,19),
        (12,14), (14,16), (16,18), (16,20), (16,22), (18,20),
        (11,23), (12,24), (23,24), (23,25), (24,26), (25,27), (26,28),
        (27,29), (28,30), (29,31), (30,32), (27,31), (28,32)
    ]

    var body: some View {
        Canvas { context, size in
            func point(_ index: Int) -> CGPoint {
                CGPoint(x: CGFloat(landmarks[index].x) * size.width,
                        y: CGFloat(landmarks[index].y) * size.height)
            }
            guard landmarks.count == 33,
                  landmarks.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return }
            var lines = Path()
            for (start, end) in Self.connections {
                lines.move(to: point(start))
                lines.addLine(to: point(end))
            }
            context.stroke(lines, with: .color(.black.opacity(0.65)), lineWidth: 5)
            context.stroke(lines, with: .color(.cyan), lineWidth: 2.5)
            for index in landmarks.indices {
                let p = point(index)
                let circle = Path(ellipseIn: CGRect(x: p.x - 3.5, y: p.y - 3.5, width: 7, height: 7))
                context.fill(circle, with: .color(.yellow))
                context.stroke(circle, with: .color(.black), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
        .accessibilityElement()
        .accessibilityLabel(Text("pose_skeleton"))
        .accessibilityValue(Text(verbatim: "\(landmarks.count)"))
        .accessibilityIdentifier("poseSkeletonOverlay")
    }
}
