import SwiftUI

enum WeekLayoutCalculator {
    static func calculate(totalWidth: CGFloat) -> WeekLayout {
        let sidePadding: CGFloat = 0
        let arrowWidth: CGFloat = 44
        let daySpacing: CGFloat = 6
        let edgeSpacing: CGFloat = 4

        let dayWidth = max(
            (totalWidth - sidePadding * 2 - arrowWidth * 2 - edgeSpacing * 2 - daySpacing * 6) / 7,
            0
        )
        return WeekLayout(
            sidePadding: sidePadding,
            arrowWidth: arrowWidth,
            dayWidth: dayWidth,
            daySpacing: daySpacing
        )
    }
}
