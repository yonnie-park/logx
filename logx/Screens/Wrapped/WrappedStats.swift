import Foundation
import CoreLocation
import SwiftUI
struct WrappedStats {
    let workouts: [WorkoutModel]
    

    var totalSessions: Int {
        workouts.count
    }

    var totalActiveKcal: Int {
        workouts.map(\.activeKcal).reduce(0, +)
    }

    var totalKm: Double {
        workouts.compactMap(\.distance).reduce(0, +) / 1000
    }

    var totalHours: Double {
        workouts.map(\.duration).reduce(0, +) / 3600
    }

    var formattedTotalHours: String {
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        return String(format: "%d:%02d", hours, minutes)
    }
    
    let month: Date  // 추가

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMMM"
        return f
    }()

    private var monthName: String {
        Self.monthFormatter.string(from: month).uppercased()
    }
    var motivationalTitle: (prefix: String, highlight: String, suffix: String) {
        let sessions = totalSessions
        let uniqueTypes = Set(workouts.map(\.type)).count

        let options: [(String, String, String)]

        if sessions <= 3 {
            options = [
                ("a slow", monthName, "."),
                ("baby steps in", monthName, "."),
            ]
        } else if sessions <= 5 {
            options = [
                ("not bad!", monthName, "."),
                ("room to grow in", monthName, "."),
                ("you showed up in", monthName, "."),
            ]
        } else if uniqueTypes >= 4 {
            options = [
                ("you explored a lot in", monthName, "."),
                ("jack of all trades,", monthName, "."),
            ]
        } else if totalHours >= 20 {
            options = [
                ("you went crazy on", monthName, "."),
                ("did you sleep in", monthName, "?"),
                ("absolutely unhinged in", monthName, "."),
                ("no days off in", monthName, "."),
            ]
        } else if totalHours >= 10 {
            options = [
                ("you absolutely crushed", monthName, "."),
                ("legendary", monthName, "."),
                ("you owned", monthName, "."),
                ("unstoppable in", monthName, "."),
            ]
        } else if sessions >= 15 {
            options = [
                ("you were unstoppable", monthName, "."),
                ("never skipped in", monthName, "."),
                ("showed up every time in", monthName, "."),
            ]
        } else {
            options = [
                ("you crushed", monthName, "."),
                ("solid work in", monthName, "."),
                ("you showed up in", monthName, "."),
            ]
        }

        return options.randomElement() ?? ("you crushed", monthName, ".")
    }

    // Top 3 get accent colors, rest get dimmed white
    var donutSlices: [DonutSlice] {
        let counts = Dictionary(grouping: workouts, by: \.type)
            .mapValues(\.count)
            .sorted { $0.value > $1.value }

        let total = counts.map(\.value).reduce(0, +)
        guard total > 0 else { return [] }

        return counts.enumerated().map { index, entry in
            let percentage = Int((Double(entry.value) / Double(total)) * 100)
            // 순서대로 투명도 낮아짐
            let opacity = max(0.15, 1.0 - Double(index) * 0.2)
            let color = Color.fitRed.opacity(opacity)
            return DonutSlice(id: entry.key, label: entry.key, percentage: percentage, color: color)
        }
    }
    var allHeartRateSamples: [HeartRateSample] {
        workouts.flatMap { $0.heartRateSamples }
            .sorted { $0.time < $1.time }
    }

    var averageHeartRate: Int? {
        let allBpm = workouts.flatMap { $0.heartRateSamples }.map(\.bpm)
        guard !allBpm.isEmpty else { return nil }
        return allBpm.reduce(0, +) / allBpm.count
    }
}

struct DonutSlice: Identifiable {
    let id: String
    let label: String
    let percentage: Int
    let color: Color
}
