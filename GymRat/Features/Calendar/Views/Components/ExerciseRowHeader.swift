import SwiftUI

struct ExerciseRowHeader: View {
    private let name: String
    private let isSharedHistory: Bool
    private let selectionIndex: Int
    private let accentColor: Color
    private let seed: ExerciseRepo.ExerciseSeed?

    init(
        name: String,
        isSharedHistory: Bool,
        selectionIndex: Int,
        accentColor: Color,
        seed: ExerciseRepo.ExerciseSeed?
    ) {
        self.name = name
        self.isSharedHistory = isSharedHistory
        self.selectionIndex = selectionIndex
        self.accentColor = accentColor
        self.seed = seed
    }


    var body: some View {
        HStack {
            Text(name)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            if isSharedHistory {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(accentColor)
                    .font(.system(size: 16))
                    .fixedSize()
            }

            Spacer()

            if selectionIndex > 0 {
                ZStack {
                    Circle()
                        .fill(accentColor)
                    Text("\(selectionIndex)")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(width: 22, height: 22)
                .fixedSize()
            }

            if let seed {
                ExerciseDetailsButton(seed: seed)
                    .fixedSize()
            }
        }
    }
}
