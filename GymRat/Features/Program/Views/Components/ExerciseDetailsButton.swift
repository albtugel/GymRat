import SwiftUI

struct ExerciseDetailsButton: View {
    let seed: ExerciseRepo.ExerciseSeed
    @State private var showSheet = false
    @Environment(\.viewModelFactory) private var viewModelFactory

    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("exerciseDetailsButton")
        .accessibilityLabel(Text("details_info_button_label"))
        .sheet(isPresented: $showSheet) {
            ExerciseDetailsView(viewModel: viewModelFactory.makeExerciseDetailsViewModel(seed: seed))
        }
    }
}
