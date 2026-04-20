import SwiftUI
import HealthKit

struct ManualWorkoutType: Identifiable, Hashable {
    let id: String
    let displayName: String
    let activityType: HKWorkoutActivityType
    let supportsDistance: Bool

    static let options: [ManualWorkoutType] = [
        .init(id: "outdoor run", displayName: "outdoor run", activityType: .running, supportsDistance: true),
        .init(id: "outdoor walk", displayName: "outdoor walk", activityType: .walking, supportsDistance: true),
        .init(id: "cycling", displayName: "cycling", activityType: .cycling, supportsDistance: true),
        .init(id: "hiking", displayName: "hiking", activityType: .hiking, supportsDistance: true),
        .init(id: "strength training", displayName: "strength training", activityType: .traditionalStrengthTraining, supportsDistance: false),
        .init(id: "functional strength", displayName: "functional strength", activityType: .functionalStrengthTraining, supportsDistance: false),
        .init(id: "cross training", displayName: "cross training", activityType: .crossTraining, supportsDistance: false),
        .init(id: "hiit", displayName: "hiit", activityType: .highIntensityIntervalTraining, supportsDistance: false),
        .init(id: "yoga", displayName: "yoga", activityType: .yoga, supportsDistance: false),
        .init(id: "pilates", displayName: "pilates", activityType: .pilates, supportsDistance: false),
        .init(id: "barre", displayName: "barre", activityType: .barre, supportsDistance: false),
        .init(id: "core training", displayName: "core training", activityType: .coreTraining, supportsDistance: false),
        .init(id: "flexibility", displayName: "flexibility", activityType: .flexibility, supportsDistance: false),
        .init(id: "cooldown", displayName: "cooldown", activityType: .cooldown, supportsDistance: false),
        .init(id: "mind & body", displayName: "mind & body", activityType: .mindAndBody, supportsDistance: false),
        .init(id: "tai chi", displayName: "tai chi", activityType: .taiChi, supportsDistance: false),
        .init(id: "dance", displayName: "dance", activityType: .cardioDance, supportsDistance: false),
        .init(id: "social dance", displayName: "social dance", activityType: .socialDance, supportsDistance: false),
        .init(id: "kickboxing", displayName: "kickboxing", activityType: .kickboxing, supportsDistance: false),
        .init(id: "boxing", displayName: "boxing", activityType: .boxing, supportsDistance: false),
        .init(id: "martial arts", displayName: "martial arts", activityType: .martialArts, supportsDistance: false),
        .init(id: "wrestling", displayName: "wrestling", activityType: .wrestling, supportsDistance: false),
        .init(id: "climbing", displayName: "climbing", activityType: .climbing, supportsDistance: false),
        .init(id: "gymnastics", displayName: "gymnastics", activityType: .gymnastics, supportsDistance: false),
        .init(id: "swimming", displayName: "swimming", activityType: .swimming, supportsDistance: false),
        .init(id: "water fitness", displayName: "water fitness", activityType: .waterFitness, supportsDistance: false),
        .init(id: "surfing", displayName: "surfing", activityType: .surfingSports, supportsDistance: false),
        .init(id: "paddling", displayName: "paddling", activityType: .paddleSports, supportsDistance: false),
        .init(id: "rowing", displayName: "rowing", activityType: .rowing, supportsDistance: false),
        .init(id: "sailing", displayName: "sailing", activityType: .sailing, supportsDistance: false),
        .init(id: "elliptical", displayName: "elliptical", activityType: .elliptical, supportsDistance: false),
        .init(id: "stair stepper", displayName: "stair stepper", activityType: .stairClimbing, supportsDistance: false),
        .init(id: "stairs", displayName: "stairs", activityType: .stairs, supportsDistance: false),
        .init(id: "step training", displayName: "step training", activityType: .stepTraining, supportsDistance: false),
        .init(id: "jump rope", displayName: "jump rope", activityType: .jumpRope, supportsDistance: false),
        .init(id: "mixed cardio", displayName: "mixed cardio", activityType: .mixedCardio, supportsDistance: false),
        .init(id: "tennis", displayName: "tennis", activityType: .tennis, supportsDistance: false),
        .init(id: "table tennis", displayName: "table tennis", activityType: .tableTennis, supportsDistance: false),
        .init(id: "badminton", displayName: "badminton", activityType: .badminton, supportsDistance: false),
        .init(id: "pickleball", displayName: "pickleball", activityType: .pickleball, supportsDistance: false),
        .init(id: "squash", displayName: "squash", activityType: .squash, supportsDistance: false),
        .init(id: "racquetball", displayName: "racquetball", activityType: .racquetball, supportsDistance: false),
        .init(id: "basketball", displayName: "basketball", activityType: .basketball, supportsDistance: false),
        .init(id: "soccer", displayName: "soccer", activityType: .soccer, supportsDistance: false),
        .init(id: "volleyball", displayName: "volleyball", activityType: .volleyball, supportsDistance: false),
        .init(id: "baseball", displayName: "baseball", activityType: .baseball, supportsDistance: false),
        .init(id: "softball", displayName: "softball", activityType: .softball, supportsDistance: false),
        .init(id: "american football", displayName: "american football", activityType: .americanFootball, supportsDistance: false),
        .init(id: "rugby", displayName: "rugby", activityType: .rugby, supportsDistance: false),
        .init(id: "hockey", displayName: "hockey", activityType: .hockey, supportsDistance: false),
        .init(id: "handball", displayName: "handball", activityType: .handball, supportsDistance: false),
        .init(id: "lacrosse", displayName: "lacrosse", activityType: .lacrosse, supportsDistance: false),
        .init(id: "bowling", displayName: "bowling", activityType: .bowling, supportsDistance: false),
        .init(id: "golf", displayName: "golf", activityType: .golf, supportsDistance: false),
        .init(id: "archery", displayName: "archery", activityType: .archery, supportsDistance: false),
        .init(id: "fencing", displayName: "fencing", activityType: .fencing, supportsDistance: false),
        .init(id: "skating", displayName: "skating", activityType: .skatingSports, supportsDistance: false),
        .init(id: "snowboarding", displayName: "snowboarding", activityType: .snowboarding, supportsDistance: false),
        .init(id: "snow sports", displayName: "snow sports", activityType: .snowSports, supportsDistance: false),
        .init(id: "skiing", displayName: "skiing", activityType: .downhillSkiing, supportsDistance: false),
        .init(id: "cross country skiing", displayName: "cross country skiing", activityType: .crossCountrySkiing, supportsDistance: false),
        .init(id: "equestrian", displayName: "equestrian", activityType: .equestrianSports, supportsDistance: false),
        .init(id: "workout", displayName: "workout", activityType: .other, supportsDistance: false),
    ]
}

struct ManualWorkoutEntryView: View {
    var onSaved: ((WorkoutModel) -> Void)? = nil

    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: ManualWorkoutType = ManualWorkoutType.options[0]
    @State private var startDate: Date = Date().addingTimeInterval(-3600)
    @State private var durationMinutes: Int = 30
    @State private var activeKcal: Int = 200
    @State private var distanceKm: Double = 5.0
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingTypePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    typeSection
                    dateSection
                    durationSection
                    kcalSection
                    if selectedType.supportsDistance {
                        distanceSection
                    }
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.fitRed)
                    }
                }
                .padding(20)
            }
            .background(Color.fitBg)
            .scrollIndicators(.hidden)
            .navigationTitle("add workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                        .foregroundColor(.fitText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        if isSaving {
                            ProgressView().tint(.fitText)
                        } else {
                            Text("save")
                                .font(.a2zBold(size: 14))
                                .foregroundColor(.fitRed)
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("activity")
                .font(.a2zBold(size: 14))
                .foregroundColor(.fitMuted)

            Button {
                showingTypePicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: workoutIconName(for: selectedType.displayName))
                        .font(.system(size: 18))
                        .foregroundColor(.fitRed)
                        .frame(width: 32)

                    Text(LocalizedStringKey(selectedType.displayName))
                        .font(.a2zBold(size: 16))
                        .foregroundColor(.fitText)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.fitMuted)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.fitBgBtn))
            }
            .accessibilityIdentifier("activity-picker")
        }
        .sheet(isPresented: $showingTypePicker) {
            ManualWorkoutTypePickerView(selected: $selectedType)
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("when")
                .font(.a2zBold(size: 14))
                .foregroundColor(.fitMuted)

            DatePicker(
                "",
                selection: $startDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .tint(.fitRed)
        }
    }

    private var durationSection: some View {
        NumberStepperRow(
            label: "duration (min)",
            value: $durationMinutes,
            step: 5,
            range: 1...600
        )
    }

    private var kcalSection: some View {
        NumberStepperRow(
            label: "active kcal",
            value: $activeKcal,
            step: 10,
            range: 0...5000
        )
    }

    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("distance (km)")
                .font(.a2zBold(size: 14))
                .foregroundColor(.fitMuted)

            HStack {
                Text(String(format: "%.2f", distanceKm))
                    .font(.a2zBold(size: 28))
                    .foregroundColor(.fitText)
                Spacer()
                Stepper("", value: $distanceKm, in: 0...500, step: 0.1)
                    .labelsHidden()
                    .tint(.fitRed)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.fitBgBtn))
        }
    }

    private func save() {
        Task {
            isSaving = true
            errorMessage = nil
            do {
                let created = try await healthKitManager.saveManualWorkout(
                    activityType: selectedType.activityType,
                    start: startDate,
                    duration: TimeInterval(durationMinutes * 60),
                    activeKcal: activeKcal,
                    distanceMeters: selectedType.supportsDistance ? distanceKm * 1000 : nil
                )
                onSaved?(created)
                dismiss()
            } catch {
                errorMessage = "failed to save. enable health write access in settings → health → data access."
            }
            isSaving = false
        }
    }
}

struct ManualWorkoutTypePickerView: View {
    @Binding var selected: ManualWorkoutType
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""

    private var filtered: [ManualWorkoutType] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return ManualWorkoutType.options }
        return ManualWorkoutType.options.filter {
            $0.displayName.lowercased().contains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    Text("no matches")
                        .font(.system(size: 14))
                        .foregroundColor(.fitMuted)
                        .listRowBackground(Color.fitBg)
                } else {
                    ForEach(filtered) { option in
                        Button {
                            selected = option
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: workoutIconName(for: option.displayName))
                                    .font(.system(size: 16))
                                    .foregroundColor(.fitRed)
                                    .frame(width: 28)
                                Text(LocalizedStringKey(option.displayName))
                                    .font(.a2zBold(size: 15))
                                    .foregroundColor(.fitText)
                                Spacer()
                                if option.id == selected.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.fitRed)
                                }
                            }
                        }
                        .listRowBackground(Color.fitBgBtn)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.fitBg)
            .navigationTitle("activity")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "search activities")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                        .foregroundColor(.fitText)
                }
            }
        }
    }
}

private struct NumberStepperRow: View {
    let label: String
    @Binding var value: Int
    let step: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(label))
                .font(.a2zBold(size: 14))
                .foregroundColor(.fitMuted)

            HStack {
                Text("\(value)")
                    .font(.a2zBold(size: 28))
                    .foregroundColor(.fitText)
                Spacer()
                Stepper("", value: $value, in: range, step: step)
                    .labelsHidden()
                    .tint(.fitRed)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.fitBgBtn))
        }
    }
}

#Preview {
    ManualWorkoutEntryView()
        .environment(HealthKitManager())
}
