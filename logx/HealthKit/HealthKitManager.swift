import Foundation
import HealthKit
import CoreLocation
import WidgetKit

@Observable
class HealthKitManager {
    var workouts: [WorkoutModel] = []
    var isAuthorized = false
    var isLoading = false

    private let store = HKHealthStore()

    private let readTypes: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.basalEnergyBurned),
        HKQuantityType(.heartRate),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.distanceCycling),
        HKSeriesType.workoutRoute()
    ]

    private let shareTypes: Set<HKSampleType> = [
        HKObjectType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.distanceCycling)
    ]

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            #if DEBUG
            print("❌ HealthKit 사용 불가")
            #endif
            return
        }
        do {
            try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
            isAuthorized = true
            #if DEBUG
            print("✅ HealthKit 권한 획득")
            #endif
            await fetchWorkouts()
        } catch {
            #if DEBUG
            print("❌ HealthKit 권한 에러: \(error)")
            #endif
        }
    }

    func fetchWorkouts() async {
        isLoading = true
        #if DEBUG
        print("🏃 fetchWorkouts 시작")
        #endif

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: nil,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let self, let hkWorkouts = samples as? [HKWorkout], error == nil else { return }

            Task.detached(priority: .background) { [weak self] in
                guard let self else { return }

                // 기본 정보만 빠르게 로드 (HR, route 제외) — 병렬 fetch
                let appBundleId = Bundle.main.bundleIdentifier ?? ""
                let result = await withTaskGroup(of: WorkoutModel.self, returning: [WorkoutModel].self) { group in
                    for hkWorkout in hkWorkouts {
                        group.addTask {
                            let activeKcal = await self.fetchActiveKcal(for: hkWorkout)
                            let totalKcal = await self.fetchTotalKcal(for: hkWorkout)
                            return WorkoutModel(
                                id: hkWorkout.uuid,
                                type: hkWorkout.workoutActivityType.name,
                                date: hkWorkout.startDate,
                                duration: hkWorkout.duration,
                                activeKcal: activeKcal,
                                totalKcal: totalKcal,
                                distance: hkWorkout.totalDistance?.doubleValue(for: .meter()),
                                heartRateSamples: [],
                                routeCoordinates: [],
                                isManual: hkWorkout.sourceRevision.source.bundleIdentifier == appBundleId
                            )
                        }
                    }
                    var models: [WorkoutModel] = []
                    for await model in group {
                        models.append(model)
                    }
                    return models.sorted { $0.date > $1.date }
                }

                SharedDataManager.save(workouts: result)
                WidgetCenter.shared.reloadAllTimelines()

                await MainActor.run {
                    self.workouts = result
                    self.isLoading = false
                    #if DEBUG
                    print("✅ 최종 모델 수: \(result.count)")
                    #endif
                }
            }
        }
        store.execute(query)
    }

    func saveManualWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        duration: TimeInterval,
        activeKcal: Int,
        distanceMeters: Double?
    ) async throws -> WorkoutModel {
        let end = start.addingTimeInterval(duration)

        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        if activityType == .running || activityType == .walking || activityType == .hiking {
            config.locationType = .outdoor
        }

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())

        try await builder.beginCollection(at: start)

        var samples: [HKSample] = []

        if activeKcal > 0 {
            let energySample = HKCumulativeQuantitySample(
                type: HKQuantityType(.activeEnergyBurned),
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: Double(activeKcal)),
                start: start,
                end: end
            )
            samples.append(energySample)
        }

        if let distanceMeters, distanceMeters > 0 {
            let distanceType: HKQuantityType = activityType == .cycling
                ? HKQuantityType(.distanceCycling)
                : HKQuantityType(.distanceWalkingRunning)
            let distanceSample = HKCumulativeQuantitySample(
                type: distanceType,
                quantity: HKQuantity(unit: .meter(), doubleValue: distanceMeters),
                start: start,
                end: end
            )
            samples.append(distanceSample)
        }

        if !samples.isEmpty {
            try await builder.addSamples(samples)
        }

        try await builder.endCollection(at: end)
        let hkWorkout = try await builder.finishWorkout()

        await fetchWorkouts()

        guard let hkWorkout else {
            throw NSError(domain: "LogX", code: -1, userInfo: [NSLocalizedDescriptionKey: "failed to finalize workout"])
        }
        return await makeWorkoutModel(from: hkWorkout)
    }

    func deleteWorkout(_ workout: WorkoutModel) async throws {
        guard let hkWorkout = await fetchHKWorkout(id: workout.id) else {
            throw NSError(domain: "LogX", code: -2, userInfo: [NSLocalizedDescriptionKey: "workout not found"])
        }
        try await store.delete(hkWorkout)
        await fetchWorkouts()
    }

    func makeWorkoutModel(from workout: WorkoutModel) async -> WorkoutModel {
        guard let hkWorkout = await fetchHKWorkout(id: workout.id) else { return workout }
        return await makeWorkoutModel(from: hkWorkout)
    }

    private func fetchHKWorkout(id: UUID) async -> HKWorkout? {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForObject(with: id)
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, _ in
                continuation.resume(returning: samples?.first as? HKWorkout)
            }
            store.execute(query)
        }
    }
    
    func makeWorkoutModel(from hkWorkout: HKWorkout) async -> WorkoutModel {
        let activeKcal = await fetchActiveKcal(for: hkWorkout)
        let totalKcal = await fetchTotalKcal(for: hkWorkout)
        let heartRateSamples = await fetchHeartRate(for: hkWorkout)
        let routeCoordinates = await fetchRoute(for: hkWorkout)

        let appBundleId = Bundle.main.bundleIdentifier ?? ""
        return WorkoutModel(
            id: hkWorkout.uuid,
            type: hkWorkout.workoutActivityType.name,
            date: hkWorkout.startDate,
            duration: hkWorkout.duration,
            activeKcal: activeKcal,
            totalKcal: totalKcal,
            distance: hkWorkout.totalDistance?.doubleValue(for: .meter()),
            heartRateSamples: heartRateSamples,
            routeCoordinates: routeCoordinates,
            isManual: hkWorkout.sourceRevision.source.bundleIdentifier == appBundleId
        )

    }

    private func fetchActiveKcal(for workout: HKWorkout) async -> Int {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(.activeEnergyBurned),
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: Int(kcal))
            }
            store.execute(query)
        }
    }

    private func fetchTotalKcal(for workout: HKWorkout) async -> Int {
        let active = await fetchActiveKcal(for: workout)
        let basal: Int = await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(.basalEnergyBurned),
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: Int(kcal))
            }
            store.execute(query)
        }
        return active + basal
    }

    func fetchHeartRate(for workout: HKWorkout) async -> [HeartRateSample] {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(
                sampleType: HKQuantityType(.heartRate),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let hrSamples = (samples as? [HKQuantitySample])?.map { sample in
                    HeartRateSample(
                        time: sample.startDate,
                        bpm: Int(sample.quantity.doubleValue(for: .init(from: "count/min")))
                    )
                } ?? []
                continuation.resume(returning: hrSamples)
            }
            store.execute(query)
        }
    }

    func fetchRoute(for workout: HKWorkout) async -> [CLLocationCoordinate2D] {
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)

        return await withCheckedContinuation { continuation in
            let routeQuery = HKSampleQuery(
                sampleType: routeType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { [weak self] _, samples, _ in
                guard let self,
                      let route = samples?.first as? HKWorkoutRoute else {
                    continuation.resume(returning: [])
                    return
                }
                Task {
                    let coords = await self.fetchRouteCoordinates(from: route)
                    continuation.resume(returning: coords)
                }
            }
            store.execute(routeQuery)
        }
    }
    
    func enableBackgroundDelivery() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        do {
            try await store.enableBackgroundDelivery(
                for: .workoutType(),
                frequency: .immediate
            )
            #if DEBUG
            print("✅ Background delivery 활성화")
            #endif
            setupObserverQuery()
        } catch {
            #if DEBUG
            print("❌ Background delivery 에러: \(error)")
            #endif
        }
    }

    private func setupObserverQuery() {
        let query = HKObserverQuery(
            sampleType: .workoutType(),
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            guard error == nil else {
                completionHandler()
                return
            }
            Task {
                await self?.handleNewWorkout()
                completionHandler()
            }
        }
        store.execute(query)
    }

    private func handleNewWorkout() async {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, _ in
            guard let workout = samples?.first as? HKWorkout else { return }
            Task {
                let kcal = Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
                await NotificationManager.shared.sendWorkoutNotification(
                    type: workout.workoutActivityType.name,
                    duration: workout.duration,
                    kcal: kcal,
                    workoutId: workout.uuid
                )
            }
        }
        store.execute(query)
    }

    private func fetchRouteCoordinates(from route: HKWorkoutRoute) async -> [CLLocationCoordinate2D] {
        await withCheckedContinuation { continuation in
            var coordinates: [CLLocationCoordinate2D] = []
            let query = HKWorkoutRouteQuery(route: route) { _, locations, done, _ in
                if let locations {
                    coordinates.append(contentsOf: locations.map(\.coordinate))
                }
                if done {
                    continuation.resume(returning: coordinates)
                }
            }
            store.execute(query)
        }
    }
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .archery:                          return "archery"
        case .badminton:                        return "badminton"
        case .barre:                            return "barre"
        case .baseball:                         return "baseball"
        case .basketball:                       return "basketball"
        case .bowling:                          return "bowling"
        case .boxing:                           return "boxing"
        case .climbing:                         return "climbing"
        case .cooldown:                         return "cooldown"
        case .coreTraining:                     return "core training"
        case .cricket:                          return "cricket"
        case .crossTraining:                    return "cross training"
        case .curling:                          return "curling"
        case .cycling:                          return "cycling"
        case .dance:                            return "dance"
        case .discSports:                       return "disc sports"
        case .elliptical:                       return "elliptical"
        case .equestrianSports:                 return "equestrian sports"
        case .fencing:                          return "fencing"
        case .fishing:                          return "fishing"
        case .fitnessGaming:                    return "fitness gaming"
        case .flexibility:                      return "flexibility"
        case .americanFootball:                 return "american football"
        case .australianFootball:               return "australian football"
        case .functionalStrengthTraining:       return "functional strength"
        case .golf:                             return "golf"
        case .gymnastics:                       return "gymnastics"
        case .handCycling:                      return "hand cycling"
        case .handball:                         return "handball"
        case .highIntensityIntervalTraining:    return "hiit"
        case .hiking:                           return "hiking"
        case .hockey:                           return "hockey"
        case .hunting:                          return "hunting"
        case .jumpRope:                         return "jump rope"
        case .kickboxing:                       return "kickboxing"
        case .lacrosse:                         return "lacrosse"
        case .martialArts:                      return "martial arts"
        case .mindAndBody:                      return "mind & body"
        case .mixedCardio:                      return "mixed cardio"
        case .paddleSports:                     return "paddling"
        case .pickleball:                       return "pickleball"
        case .pilates:                          return "pilates"
        case .play:                             return "play"
        case .racquetball:                      return "racquetball"
        case .rowing:                           return "rowing"
        case .rugby:                            return "rugby"
        case .running:                          return "outdoor run"
        case .sailing:                          return "sailing"
        case .skatingSports:                    return "skating"
        case .snowSports:                       return "snow sports"
        case .snowboarding:                     return "snowboarding"
        case .soccer:                           return "soccer"
        case .softball:                         return "softball"
        case .squash:                           return "squash"
        case .stairClimbing:                    return "stair stepper"
        case .stairs:                           return "stairs"
        case .stepTraining:                     return "step training"
        case .surfingSports:                    return "surfing"
        case .swimming:                         return "swimming"
        case .tableTennis:                      return "table tennis"
        case .taiChi:                           return "tai chi"
        case .tennis:                           return "tennis"
        case .trackAndField:                    return "track & field"
        case .traditionalStrengthTraining:      return "strength training"
        case .volleyball:                       return "volleyball"
        case .walking:                          return "outdoor walk"
        case .waterFitness:                     return "water fitness"
        case .waterPolo:                        return "water polo"
        case .waterSports:                      return "water sports"
        case .wheelchairRunPace:                return "wheelchair run"
        case .wheelchairWalkPace:               return "wheelchair walk"
        case .wrestling:                        return "wrestling"
        case .yoga:                             return "yoga"
        case .socialDance:                      return "social dance"
        case .other:                            return "workout"
        case .cardioDance:                      return "cardio dance"
        case .swimBikeRun:                      return "triathlon"
        case .transition:                       return "transition"
        case .underwaterDiving:                 return "underwater diving"
        default:
            switch self.rawValue {
            case 52: return "outdoor walk"
            case 58: return "barre"
            case 41: return "soccer"
            case 64: return "jump rope"
            case 44: return "stair stepper"
            case 48: return "tennis"
            case 37: return "outdoor run"
            case 57: return "yoga"
            case 20: return "strength training"
            default: return "workout"
            }
        }
    }
}
