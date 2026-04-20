import Foundation
import HealthKit
import CoreLocation

struct WorkoutModel: Identifiable, Hashable {
    let id: UUID
    let type: String
    let date: Date
    let duration: TimeInterval
    let activeKcal: Int
    let totalKcal: Int
    let distance: Double?
    let heartRateSamples: [HeartRateSample]
    let routeCoordinates: [CLLocationCoordinate2D]
    let isManual: Bool

    static func == (lhs: WorkoutModel, rhs: WorkoutModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var averageHeartRate: Int? {
        guard !heartRateSamples.isEmpty else { return nil }
        let avg = heartRateSamples.map(\.bpm).reduce(0, +) / heartRateSamples.count
        return avg
    }

    var hasRoute: Bool {
        let routeTypes = ["outdoor run", "walking", "outdoor walk"]
        return routeTypes.contains(type.lowercased()) && !routeCoordinates.isEmpty
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedDistance: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.1fkm", distance / 1000)
    }

    var isRun: Bool {
        type.lowercased().contains("run")
    }

    var formattedPace: String? {
        guard isRun,
              let distance = distance,
              distance >= 100,
              duration > 0 else { return nil }
        let secondsPerKm = duration / (distance / 1000)
        let minutes = Int(secondsPerKm) / 60
        let seconds = Int(secondsPerKm) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }

    static let mock = WorkoutModel(
        id: UUID(),
        type: "outdoor run",
        date: Date(),
        duration: 3600,
        activeKcal: 290,
        totalKcal: 321,
        distance: 5200,
        heartRateSamples: HeartRateSample.mockSamples,
        routeCoordinates: CLLocationCoordinate2D.mockRoute,
        isManual: false
    )

    static let mockList: [WorkoutModel] = [
        WorkoutModel(id: UUID(), type: "outdoor run", date: Date(), duration: 3600, activeKcal: 290, totalKcal: 321, distance: 5200, heartRateSamples: HeartRateSample.mockSamples, routeCoordinates: CLLocationCoordinate2D.mockRoute, isManual: false),
        WorkoutModel(id: UUID(), type: "barre", date: Date().addingTimeInterval(-86400), duration: 2700, activeKcal: 185, totalKcal: 210, distance: nil, heartRateSamples: HeartRateSample.mockSamples, routeCoordinates: [], isManual: true),
        WorkoutModel(id: UUID(), type: "hiit", date: Date().addingTimeInterval(-172800), duration: 1800, activeKcal: 255, totalKcal: 280, distance: nil, heartRateSamples: HeartRateSample.mockSamples, routeCoordinates: [], isManual: false),
        WorkoutModel(id: UUID(), type: "cycling", date: Date().addingTimeInterval(-259200), duration: 4500, activeKcal: 350, totalKcal: 390, distance: 18000, heartRateSamples: HeartRateSample.mockSamples, routeCoordinates: [], isManual: false),
    ]
}

struct HeartRateSample: Identifiable {
    let id = UUID()
    let time: Date
    let bpm: Int

    static let mockSamples: [HeartRateSample] = {
        let start = Date().addingTimeInterval(-3600)
        let bpms = [72, 95, 118, 135, 142, 138, 155, 160, 158, 152, 148, 155, 162, 158, 145, 138, 130, 125, 118, 110]
        return bpms.enumerated().map { i, bpm in
            HeartRateSample(time: start.addingTimeInterval(Double(i) * 180), bpm: bpm)
        }
    }()
}

extension CLLocationCoordinate2D {
    static let mockRoute: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.5326, longitude: 127.0246),
        CLLocationCoordinate2D(latitude: 37.5330, longitude: 127.0252),
        CLLocationCoordinate2D(latitude: 37.5335, longitude: 127.0261),
        CLLocationCoordinate2D(latitude: 37.5340, longitude: 127.0270),
        CLLocationCoordinate2D(latitude: 37.5338, longitude: 127.0282),
        CLLocationCoordinate2D(latitude: 37.5332, longitude: 127.0290),
        CLLocationCoordinate2D(latitude: 37.5325, longitude: 127.0285),
        CLLocationCoordinate2D(latitude: 37.5318, longitude: 127.0275),
        CLLocationCoordinate2D(latitude: 37.5320, longitude: 127.0263),
        CLLocationCoordinate2D(latitude: 37.5326, longitude: 127.0246),
    ]
}
