import SwiftUI
import Photos

struct WrappedView: View {
    let workouts: [WorkoutModel]
    let month: Date
    @State private var showSavedAlert = false
    @Environment(\.dismiss) var dismiss
    
    private var stats: WrappedStats {
        WrappedStats(workouts: workouts, month: month)
    }
    
    private var routeWorkouts: [WorkoutModel] {
        workouts.filter { $0.hasRoute }
    }
    
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }()

    private func monthName() -> String {
        Self.monthFormatter.string(from: month).lowercased()
    }
    
    
    // 저장할 콘텐츠만 따로
    var wrappedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Title
            VStack(alignment: .leading, spacing: 0) {
                Text(stats.motivationalTitle.prefix)
                    .font(.a2zBold(size: 36))
                    .foregroundColor(.fitText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(stats.motivationalTitle.highlight + stats.motivationalTitle.suffix)
                    .font(.a2zBold(size: 36))
                    .foregroundColor(.fitRed)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 16)
            
            // Card 1: Donut + legend
            HStack(alignment: .center, spacing: 40) {
                DonutChart(slices: stats.donutSlices, totalSessions: stats.totalSessions)
                    .frame(width: 90, height: 90)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(stats.donutSlices) { slice in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(slice.color)
                                .frame(width: 7, height: 7)
                            Text(slice.label)
                                .font(.a2zRegular(size: 12))
                                .foregroundColor(.fitText)
                                .lineLimit(1)
                            Spacer()
                            Text("\(slice.percentage)%")
                                .font(.a2zRegular(size: 12))
                                .foregroundColor(.fitMuted)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.fitBgBtn))
            
            
            // Card 2: Bar chart + stats
            HStack(alignment: .top, spacing: 12) {
                WeeklyBarChart(workouts: workouts, month: month)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.fitBgBtn))
                
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("total workout")
                            .font(.system(size: 11))
                            .foregroundColor(.fitMuted)
                        Text(stats.formattedTotalHours)
                            .font(.a2zBold(size: 32))
                            .foregroundColor(.fitText)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.fitBgBtn))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("total kcal")
                            .font(.system(size: 11))
                            .foregroundColor(.fitMuted)
                        Text("\(stats.totalActiveKcal)")
                            .font(.a2zBold(size: 32))
                            .foregroundColor(.fitText)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.fitBgBtn))
                }
                .frame(width: 130, height: 180)
            }
            
            // Card 3: Heart rate or heatmap
            if !stats.allHeartRateSamples.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("avg. heart rate")
                            .font(.system(size: 11))
                            .foregroundColor(.fitMuted)
                        Spacer()
                        if let avg = stats.averageHeartRate {
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text("\(avg)")
                                    .font(.a2zBold(size: 20))
                                    .foregroundColor(.fitText)
                                Text("bpm")
                                    .font(.system(size: 11))
                                    .foregroundColor(.fitMuted)
                            }
                        }
                    }
                    HeartRateGraph(
                        samples: stats.allHeartRateSamples,
                        workoutStart: stats.allHeartRateSamples.first?.time ?? Date()
                    )
                    .frame(height: 120)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.fitBgBtn))
            } else {
                WorkoutHeatmap(workouts: workouts, month: month)
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.fitBgBtn))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(Color.fitBg)
    }
    
    var body: some View {
        ZStack {
            Color.fitBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    // Back button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.fitText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    
                    // Content
                    wrappedContent
                    
                    // Save button
                    FitButton(title: "SAVE MY WRAPPED", style: .primary) {
                        saveWrapped()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .padding(.top, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 100 { dismiss() }
            }
        )
        .alert("saved to photos!", isPresented: $showSavedAlert) {
            Button("ok") { showSavedAlert = false }
        }
    }
    
    @State private var isCapturing = false
    
    @MainActor
    private func saveWrapped() {
        isCapturing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let renderer = ImageRenderer(content:
                                            wrappedContent
                .frame(width: UIScreen.main.bounds.width)
            )
            renderer.scale = UIScreen.main.scale
            renderer.isOpaque = true
            
            guard let uiImage = renderer.uiImage,
                  let pngData = uiImage.pngData(),
                  let pngImage = UIImage(data: pngData) else {
                isCapturing = false
                return
            }
            
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized else {
                    DispatchQueue.main.async { isCapturing = false }
                    return
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: pngImage)
                }) { success, _ in
                    DispatchQueue.main.async {
                        isCapturing = false
                        if success { showSavedAlert = true }
                    }
                }
            }
        }
    }
    
    // MARK: - Weekly Bar Chart
    
    struct WeeklyBarChart: View {
        let workouts: [WorkoutModel]
        let month: Date
        
        private var calendar: Calendar {
            var cal = Calendar(identifier: .gregorian)
            cal.firstWeekday = 1
            return cal
        }
        
        private var weeklyData: [Double] {
            guard let range = calendar.range(of: .weekOfMonth, in: .month, for: month) else { return [] }
            return range.map { week -> Double in
                let weekWorkouts = workouts.filter { workout in
                    let workoutWeek = calendar.component(.weekOfMonth, from: workout.date)
                    let workoutMonth = calendar.component(.month, from: workout.date)
                    let targetMonth = calendar.component(.month, from: month)
                    return workoutWeek == week && workoutMonth == targetMonth
                }
                // 운동 시간 합계 (분)
                return weekWorkouts.map(\.duration).reduce(0, +) / 60
            }
        }

        private var maxCount: Double {
            weeklyData.max() ?? 1
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("weekly workouts")
                    .font(.system(size: 11))
                    .foregroundColor(.fitMuted)
                
                GeometryReader { geo in
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, count in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color.fitText)
                                    .frame(
                                        width: (geo.size.width - CGFloat(weeklyData.count - 1) * 8) / CGFloat(weeklyData.count),
                                        height: weeklyData[index] == 0 ? 10 : CGFloat(weeklyData[index]) / CGFloat(maxCount) * (geo.size.height - 24)
                                    )
                                Text("w\(index + 1)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.fitMuted)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
        }
    }
    
    // MARK: - Workout Heatmap
    
    struct WorkoutHeatmap: View {
        let workouts: [WorkoutModel]
        let month: Date
        
        private var calendar: Calendar {
            var cal = Calendar(identifier: .gregorian)
            cal.firstWeekday = 1
            return cal
        }
        
        private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
        
        private var workoutDayTypes: [Int: String] {
            var result: [Int: String] = [:]
            for workout in workouts {
                guard calendar.isDate(workout.date, equalTo: month, toGranularity: .month) else { continue }
                let day = calendar.component(.day, from: workout.date)
                if result[day] == nil {
                    result[day] = workout.type
                }
            }
            return result
        }
        
        private var firstWeekdayOffset: Int {
            var components = calendar.dateComponents([.year, .month], from: month)
            components.day = 1
            let firstDay = calendar.date(from: components)!
            return calendar.component(.weekday, from: firstDay) - 1
        }
        
        private var daysInMonth: Int {
            calendar.range(of: .day, in: .month, for: month)!.count
        }
        
        
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    ForEach(Array(dayLabels.enumerated()), id: \.offset) { _, label in
                        Text(label)
                            .font(.system(size: 10))
                            .foregroundColor(.fitMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                        Color.clear.frame(height: 32)
                    }
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let hasWorkout = workoutDayTypes[day] != nil
                        ZStack {
                            Circle()
                                .fill(hasWorkout ? Color.fitRed : Color.clear)
                                .frame(height: 32)
                            
                            if hasWorkout, let type = workoutDayTypes[day] {
                                Image(systemName: workoutIconName(for: type))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(day)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.fitMuted)
                            }
                        }
                        .frame(height: 32)
                    }
                }
            }
        }
    }
}
