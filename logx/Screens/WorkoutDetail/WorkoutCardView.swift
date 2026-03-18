import SwiftUI

struct WorkoutCardView: View {
    let workout: WorkoutModel
    var backgroundImage: UIImage? = nil
    var isTransparent: Bool = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // Background
            if let img = backgroundImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: UIScreen.main.bounds.width - 48,
                        height: (UIScreen.main.bounds.width - 48) * 1.4
                    )
                    .clipped()

                LinearGradient(
                    colors: [Color.clear, Color.fitBlack.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if !isTransparent {
                Color.fitBg
            }

            // Content pinned to bottom
            VStack(alignment: .leading, spacing: 0) {

                // Route line
                if workout.hasRoute {
                    RouteMapView(
                        coordinates: workout.routeCoordinates,
                        lineColor: .fitRed,
                        lineWidth: 1.5
                    )
                    .frame(height: 80)
                }

                // Workout name + date
                Text(LocalizedStringKey(workout.type))
                    .font(.a2zBold(size: 32))
                    .foregroundColor(.fitWhite)

                Text(workout.formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.fitWhite.opacity(0.5))
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                // Stats
                HStack(spacing: 28) {
                    StatBlock(value: workout.formattedDuration, label: "duration")
                    StatBlock(value: "\(workout.activeKcal)", label: "kcal")
                    if let avg = workout.averageHeartRate {
                        StatBlock(value: "\(avg)", label: "bpm")
                    }
                }
                .padding(.bottom, 16)

                // Heart rate line
                if !workout.heartRateSamples.isEmpty{
                    HeartRateGraph(
                        samples: workout.heartRateSamples,
                        workoutStart: workout.date
                    )
                    .frame(height: 50)
                }
            }
            .padding(28)
        }
        .frame(
            width: UIScreen.main.bounds.width - 48,
            height: (UIScreen.main.bounds.width - 48) * 1.4
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    WorkoutCardView(workout: .mock)
        .padding()
        .background(Color.fitBg)
}
