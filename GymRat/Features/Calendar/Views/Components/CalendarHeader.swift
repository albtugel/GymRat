import SwiftUI

struct CalendarHeader: View {
    private let accentColor: Color
    private let onSettingsTap: () -> Void

    init(accentColor: Color, onSettingsTap: @escaping () -> Void) {
        self.accentColor = accentColor
        self.onSettingsTap = onSettingsTap
    }


    var body: some View {
        HStack {
            Text("app_name")
                .font(.largeTitle)
                .bold()

            Spacer()

            Button {
                onSettingsTap()
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(accentColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}
