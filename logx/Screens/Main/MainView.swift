import SwiftUI

struct MainView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate: Date? = nil

    
    private var workouts: [WorkoutModel] {
        healthKitManager.workouts
    }

    private var availableMonths: [Date] {
        let calendar = Calendar.current
        var seen = Set<DateComponents>()
        var months: [Date] = []
        for workout in workouts {
            let comp = calendar.dateComponents([.year, .month], from: workout.date)
            if seen.insert(comp).inserted {
                if let monthDate = calendar.date(from: comp) {
                    months.append(monthDate)
                }
            }
        }
        // Remove current month, sort newest first
        let currentComp = calendar.dateComponents([.year, .month], from: Date())
        return months
            .filter { calendar.dateComponents([.year, .month], from: $0) != currentComp }
            .sorted { $0 > $1 }
    }

    private var workoutsForSelectedDate: [WorkoutModel] {
        guard let date = selectedDate else { return [] }
        return workouts.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Logo
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .accessibilityLabel("Log X logo")
                
                // Wrapped chips
                if !availableMonths.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(availableMonths, id: \.self) { month in
                                NavigationLink(destination: WrappedView(
                                    workouts: workoutsFor(month: month),
                                    month: month
                                )) {
                                    WrappedMonthChip(month: month)
                                }
                                .accessibilityIdentifier("wrapped-chip")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                    .onAppear {
                        var cal = Calendar(identifier: .gregorian)
                        cal.firstWeekday = 1
                        
                        // January 2026 테스트
                        var components = DateComponents()
                        components.year = 2026
                        components.month = 1
                        components.day = 1
                        let jan1 = cal.date(from: components)!
                        let weekday = cal.component(.weekday, from: jan1)
                    }
                }
                
                

                // Calendar
                CalendarView(selectedDate: $selectedDate, workouts: workouts)

                // Selected day workouts
                if !workoutsForSelectedDate.isEmpty {
                    if let date = selectedDate {
                        Text(date.formatted(date: .long, time: .omitted).lowercased())
                            .font(.a2zBold(size: 18))
                            .foregroundColor(.fitText)
                    }

                    VStack(spacing: 10) {
                        ForEach(workoutsForSelectedDate) { workout in
                            RecentWorkoutRow(workout: workout)
                        }
                    }
                }

                // Recent label
                Text("recent")
                    .font(.a2zBold(size: 18))
                    .foregroundColor(.fitText)



                if healthKitManager.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(.fitText)
                        Spacer()
                    }
                } else if workouts.isEmpty {
                    Text("no workouts found")
                        .font(.system(size: 14))
                        .foregroundColor(.fitMuted)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(workouts) { workout in
                            RecentWorkoutRow(workout: workout)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.bottom, 40)
        }
        .background(Color.fitBg)
        .scrollIndicators(.hidden)
    }

    private func workoutsFor(month: Date) -> [WorkoutModel] {
        let calendar = Calendar.current
        return workouts.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
    }
}

// MARK: - Wrapped Month Chip

struct WrappedMonthChip: View {
    let month: Date

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f
    }()

    private var monthLabel: String {
        Self.monthFormatter.string(from: month).uppercased()
    }

    var body: some View {
        Text(monthLabel)
            .font(.a2zBold(size: 14))
            .foregroundColor(.fitWhite)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.fitRed)
            )
    }
}

#Preview {
    MainView()
        .environment(HealthKitManager())
}
