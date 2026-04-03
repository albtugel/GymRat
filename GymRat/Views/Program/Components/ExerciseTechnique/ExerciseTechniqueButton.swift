import SwiftUI

struct ExerciseTechniqueButton: View {
    let seed: ExerciseStore.ExerciseSeed
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
            ExerciseTechniqueSheet(seed: seed)
        }
    }
}
