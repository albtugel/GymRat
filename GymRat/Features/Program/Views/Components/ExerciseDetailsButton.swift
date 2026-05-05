import SwiftUI

struct ExerciseDetailsButton: View {
    let seed: ExerciseRepo.ExerciseSeed
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            ExerciseDetailsView(seed: seed)
        }
    }
}
