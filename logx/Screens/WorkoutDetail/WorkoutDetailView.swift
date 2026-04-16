import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutModel
    @State private var detailedWorkout: WorkoutModel? = nil
    @State private var showShareCard = false
    @Environment(\.dismiss) var dismiss
    @Environment(HealthKitManager.self) private var healthKitManager

    private var displayWorkout: WorkoutModel {
        detailedWorkout ?? workout
    }

    var body: some View {
        ZStack {
            Color.fitBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // Back button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.fitText)
                    }
                    .accessibilityIdentifier("nav-back")
                    .accessibilityLabel("Back")
                    .padding(.top, 16)

                    // Icon + title + date
                    VStack(alignment: .leading, spacing: 8) {
                        WorkoutIcon(type: displayWorkout.type)
                            .frame(width: 56, height: 56)

                        Text(LocalizedStringKey(displayWorkout.type))
                            .font(.a2zBold(size: 32))
                            .foregroundColor(.fitText)
                            .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
                            .padding(.bottom, 4)

                        Text(displayWorkout.formattedDate)
                            .font(.system(size: 13))
                            .foregroundColor(.fitMuted)
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(label: "workout time", value: displayWorkout.formattedDuration, color: .fitText)
                        StatCard(label: "active kcal", value: "\(displayWorkout.activeKcal)", unit: "kcal", color: .fitText)
                        StatCard(label: "total kcal", value: "\(displayWorkout.totalKcal)", unit: "kcal", color: .fitText)
                        if let avg = displayWorkout.averageHeartRate {
                            StatCard(label: "avg. heart rate", value: "\(avg)", unit: "bpm", color: .fitText)
                        }
                    }

                    // Loading indicator
                    if detailedWorkout == nil {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(.fitMuted)
                            Spacer()
                        }
                        .padding()
                    }

                    // Heart rate graph
                    if !displayWorkout.heartRateSamples.isEmpty {
                        let isRunOrWalk = displayWorkout.type.contains("run") || displayWorkout.type.contains("walk")
                        VStack(alignment: .leading, spacing: 12) {
                            Text("heart rate")
                                .font(.system(size: 13))
                                .foregroundColor(.fitMuted)

                            HeartRateGraph(
                                samples: displayWorkout.heartRateSamples,
                                workoutStart: displayWorkout.date,
                            ).frame(height: isRunOrWalk ? 200 : 160)  // 높이 늘림
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.fitBgBtn)
                        )
                    }

                    // Route map
                    if displayWorkout.hasRoute {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("route")
                                .font(.system(size: 13))
                                .foregroundColor(.fitMuted)

                            RouteMapView(coordinates: displayWorkout.routeCoordinates, lineColor: .fitRed)
                                .frame(height: 180)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.fitBgBtn)
                        )
                    }

                    // Share button
                    FitButton(title: "SHARE MY WORKOUT", style: .primary) {
                        showShareCard = true
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
        .sheet(isPresented: $showShareCard) {
            ShareCardView(workout: displayWorkout)
        }
        .onAppear {
            Task {
                let detailed = await healthKitManager.makeWorkoutModel(from: workout)
                detailedWorkout = detailed
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let label: String
    let value: String
    var unit: String? = nil
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(label))
                .font(.system(size: 11))
                .foregroundColor(.fitMuted)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.a2zBold(size: 28))
                    .foregroundColor(color)

                if let unit = unit {
                    Text(LocalizedStringKey(unit))
                        .font(.system(size: 12))
                        .foregroundColor(color.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.fitBgBtn)
        )
    }
}

#Preview {
    WorkoutDetailView(workout: .mock)
        .environment(HealthKitManager())
}
