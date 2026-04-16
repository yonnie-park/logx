import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date?
    @State private var displayedMonth: Date = Date()
    var workouts: [WorkoutModel] = []

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private var dayLabels: [String] {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        return formatter.veryShortWeekdaySymbols
    }

    
    private var workoutDayTypes: [Int: String] {
        var result: [Int: String] = [:]
        for workout in workouts {
            guard calendar.isDate(workout.date, equalTo: displayedMonth, toGranularity: .month) else { continue }
            let day = calendar.component(.day, from: workout.date)
            if result[day] == nil {
                result[day] = workout.type
            }
        }
        return result
    }

    private var firstWeekdayOffset: Int {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = 1
        let firstDay = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday - 1
    }

    private var daysInMonth: Int {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        return range.count
    }

    var body: some View {
        VStack(spacing: 16) {

            HStack {
                Button { shiftMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.fitMuted)
                }
                .accessibilityIdentifier("nav-prev-month")
                .accessibilityLabel("Previous month")
                Spacer()
                Text(monthLabel())
                    .font(.a2zBold(size: 22))
                    .foregroundColor(.fitText)
                Spacer()
                Button { shiftMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.fitMuted)
                }
                .accessibilityIdentifier("nav-next-month")
                .accessibilityLabel("Next month")
            }

            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { _, label in
                    Text(label)
                        .font(.system(size: 11))
                        .foregroundColor(.fitMuted)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<(firstWeekdayOffset + daysInMonth), id: \.self) { idx in
                    if idx < firstWeekdayOffset {
                        Color.clear
                            .frame(maxWidth: .infinity, minHeight: 40)
                    } else {
                        let day = idx - firstWeekdayOffset + 1
                        let hasWorkout = workoutDayTypes[day] != nil
                        DayCell(
                            day: day,
                            hasWorkout: hasWorkout,
                            isSelected: isSelected(day: day),
                            isToday: isToday(day: day),
                            workoutType: workoutDayTypes[day]
                        )
                        .onTapGesture {
                            guard hasWorkout else { return }
                            if isSelected(day: day) {
                                selectedDate = nil
                            } else {
                                selectedDate = dateFor(day: day)
                            }
                        }
                        .opacity(hasWorkout || isToday(day: day) ? 1.0 : 0.3)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.fitBgBtn)
        )
        .onAppear {
            var components = calendar.dateComponents([.year, .month], from: displayedMonth)
            components.day = 1
            let firstDay = calendar.date(from: components)!
            let weekday = calendar.component(.weekday, from: firstDay)
            #if DEBUG
            print("현재 달 1일 weekday: \(weekday), offset: \(weekday - 1)")
            print("현재 달: \(monthLabel())")
            #endif
        }
    }

    private func shiftMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = newMonth
        selectedDate = nil
    }

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }()

    private func monthLabel() -> String {
        Self.monthFormatter.calendar = calendar
        return Self.monthFormatter.string(from: displayedMonth).uppercased()
    }

    private func dateFor(day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = day
        return calendar.date(from: components) ?? Date()
    }

    private func isToday(day: Int) -> Bool {
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let displayed = calendar.dateComponents([.year, .month], from: displayedMonth)
        return today.year == displayed.year &&
               today.month == displayed.month &&
               today.day == day
    }

    private func isSelected(day: Int) -> Bool {
        guard let selected = selectedDate else { return false }
        return calendar.component(.day, from: selected) == day &&
               calendar.isDate(selected, equalTo: displayedMonth, toGranularity: .month)
    }
}

// MARK: - Day Cell

// DayCell에 workout type 추가
struct DayCell: View {
    let day: Int
    let hasWorkout: Bool
    let isSelected: Bool
    let isToday: Bool
    var workoutType: String? = nil  // 추가

    var body: some View {
        ZStack {
            if isSelected || hasWorkout {
                Circle()
                    .fill(Color.fitRed)
                    .frame(width: 40, height: 40)
            } else if isToday {
                Circle()
                    .strokeBorder(Color.fitRed, lineWidth: 2)
                    .frame(width: 40, height: 40)
            }

            if hasWorkout, let type = workoutType {
                // 아이콘 표시
                Image(systemName: workoutIconName(for: type))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            } else {
                // 숫자 표시
                Text("\(day)")
                    .font(.a2zRegular(size: 15))
                    .foregroundColor(isSelected || hasWorkout ? .fitWhite : .fitText)
            }
        }
        .frame(height: 40)
    }

}
