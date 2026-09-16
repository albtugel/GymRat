import SwiftUI

struct ExerciseDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseDetailsViewModel

    init(viewModel: ExerciseDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ExerciseDetailsContent(
                    imageURLs: viewModel.imageURLs,
                    placeholderSystemName: viewModel.placeholderSystemName,
                    exerciseName: viewModel.title,
                    musclesTitle: viewModel.musclesTitle,
                    muscleLabels: viewModel.muscleLabels,
                    instructionsTitle: viewModel.instructionsTitle,
                    instructions: viewModel.instructions
                )
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done_button") { dismiss() }
                }
            }
            .task {
                await viewModel.loadLatestDetails()
            }
        }
    }
}
