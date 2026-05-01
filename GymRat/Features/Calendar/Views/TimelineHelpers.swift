import SwiftUI

let hourHeight: CGFloat = 60 // 1 час = 60pt

func yOffset(for date: Date) -> CGFloat {
    let hour = Calendar.current.component(.hour, from: date)
    let minute = Calendar.current.component(.minute, from: date)
    return CGFloat(hour) * hourHeight + CGFloat(minute) / 60 * hourHeight
}

func height(for item: TimelineItem) -> CGFloat {
    CGFloat(item.endDate.timeIntervalSince(item.startDate) / 3600) * hourHeight
}
