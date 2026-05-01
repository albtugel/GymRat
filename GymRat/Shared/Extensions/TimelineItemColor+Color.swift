import SwiftUI

extension TimelineItemColor {
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
            .opacity(opacity)
    }
}
