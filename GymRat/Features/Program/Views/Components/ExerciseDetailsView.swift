import SwiftUI

struct ExerciseDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseDetailsViewModel

    init(seed: ExerciseRepo.ExerciseSeed) {
        _viewModel = State(initialValue: ExerciseDetailsViewModel(seed: seed))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ExerciseDetailsContent(
                    imageURLs: viewModel.imageURLs,
                    placeholderSystemName: viewModel.placeholderSystemName,
                    musclesTitle: viewModel.musclesTitle,
                    muscleLabels: viewModel.muscleLabels
                )
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done_button") { dismiss() }
                }
            }
        }
    }
}
