import Foundation

nonisolated struct SharedWorkout: Codable, Identifiable, Sendable {
    let id: UUID
    let type: String
    let date: Date
    let duration: TimeInterval
    let activeKcal: Int
    let totalKcal: Int
    let distance: Double?
}

nonisolated struct SharedDataManager {
    private static let suiteName = "group.com.jessie.logx"
    private static let workoutsKey = "recentWorkouts"
    private static let maxWorkouts = 100

    static func save(workouts: [WorkoutModel]) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        let shared = Array(workouts.prefix(maxWorkouts)).map { w in
            SharedWorkout(
                id: w.id,
                type: w.type,
                date: w.date,
                duration: w.duration,
                activeKcal: w.activeKcal,
                totalKcal: w.totalKcal,
                distance: w.distance
            )
        }
        if let data = try? JSONEncoder().encode(shared) {
            defaults.set(data, forKey: workoutsKey)
        }
    }

    static func load() -> [SharedWorkout] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: workoutsKey),
              let workouts = try? JSONDecoder().decode([SharedWorkout].self, from: data) else {
            return []
        }
        return workouts
    }
}
