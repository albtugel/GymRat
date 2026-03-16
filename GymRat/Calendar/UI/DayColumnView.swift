import SwiftUI

struct DayColumnView: View {
    let date: Date
    let items: [TimelineItem]

    var body: some View {
        // Берем только уникальные времена событий
        let times: [Date] = items.flatMap { [$0.startDate, $0.endDate] }
        let uniqueTimes = Array(Set(times)).sorted()

        VStack(spacing: 4) {
            ForEach(uniqueTimes, id: \.self) { time in
                HStack(spacing: 2) {
                    ForEach(items.filter { Calendar.current.isDate($0.startDate, equalTo: time, toGranularity: .minute) }) { item in
                        NavigationLink {
                            if let session = item.workoutSession {
                                WorkoutDetailView(session: session)
                            } else {
                                Text(item.title)
                                    .padding()
                            }
                        } label: {
                            TimelineItemView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .frame(height: 60)
                .overlay(
                    Text(timeLabel(time))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 2),
                    alignment: .leading
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func timeLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
