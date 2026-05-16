import SwiftUI

struct WeekArrowButton: View {
    private let systemName: String
    private let accentColor: Color
    private let onTap: () -> Void

    init(systemName: String, accentColor: Color, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.accentColor = accentColor
        self.onTap = onTap
    }


    var body: some View {
        Button(action: onTap) {
            Image(systemName: systemName)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColor, lineWidth: 2)
                )
        }
        .foregroundColor(accentColor)
    }
}
