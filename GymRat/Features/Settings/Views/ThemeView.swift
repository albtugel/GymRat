import SwiftUI

struct ThemeView: View {
    @Binding var selectedTheme: ThemeMode
    @State private var rotation: Double = 0

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.7)) {
                cycleTheme()
                rotation += 360 // плавное вращение иконки при смене
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text("theme_label")
                    .font(.headline)
                
                Image(systemName: iconName())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                    .foregroundColor(.primary)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .buttonStyle(.plain)
    }

    private func cycleTheme() {
        switch selectedTheme {
        case .system:
            selectedTheme = .light
        case .light:
            selectedTheme = .dark
        case .dark:
            selectedTheme = .system
        }
    }

    private func iconName() -> String {
        switch selectedTheme {
        case .system:
            return "desktopcomputer" // системная тема
        case .light:
            return "sun.max.fill" // светлая
        case .dark:
            return "moon.fill" // темная
        }
    }
}
