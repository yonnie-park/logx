import SwiftUI

enum CardFormat: String, CaseIterable, Identifiable {
    case post, story

    var id: String { rawValue }
    var aspectRatio: CGFloat {
        switch self {
        case .post:  return 1.0 / 1.4
        case .story: return 9.0 / 16.0
        }
    }
    var label: String {
        switch self {
        case .post:  return "post"
        case .story: return "story"
        }
    }
}

struct WorkoutCardView: View {
    let workout: WorkoutModel
    var backgroundImage: UIImage? = nil
    var isTransparent: Bool = false
    var roundedCorners: Bool = true
    var format: CardFormat = .post

    private var cardWidth: CGFloat { UIScreen.main.bounds.width - 48 }
    private var cardHeight: CGFloat { cardWidth / format.aspectRatio }

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // Background
            if let img = backgroundImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()

                LinearGradient(
                    colors: [Color.clear, Color.fitBlack.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if !isTransparent {
                Color.fitBg
            }

            // Logo pinned to bottom-right
            Image("TextLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 12)
                .opacity(0.85)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            // Content pinned to bottom
            VStack(alignment: .leading, spacing: 0) {

                // Route line
                if workout.hasRoute {
                    RouteMapView(
                        coordinates: workout.routeCoordinates,
                        lineColor: .fitRed,
                        lineWidth: 1.5
                    )
                    .frame(height: 64)
                }

                // Workout icon
                Image(systemName: workoutIconName(for: workout.type))
                    .font(.system(size: 22))
                    .foregroundColor(.fitWhite)
                    .padding(.bottom, 6)

                // Workout name + date
                Text(LocalizedStringKey(workout.type))
                    .font(.a2zBold(size: 26))
                    .foregroundColor(.fitWhite)
                    .frame(maxWidth: .infinity, minHeight: 38, alignment: .topLeading)
                    .padding(.bottom, 2)

                Text(workout.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.fitWhite.opacity(0.5))
                    .padding(.bottom, 14)

                // Stats
                HStack(spacing: 20) {
                    StatBlock(value: workout.formattedDuration, label: "duration")
                    if let pace = workout.formattedPace {
                        StatBlock(value: pace, label: "pace /km")
                    }
                    StatBlock(value: "\(workout.activeKcal)", label: "kcal")
                    if let avg = workout.averageHeartRate {
                        StatBlock(value: "\(avg)", label: "bpm")
                    }
                }
                .padding(.bottom, 12)

                // Heart rate line
                if !workout.heartRateSamples.isEmpty{
                    HeartRateGraph(
                        samples: workout.heartRateSamples,
                        workoutStart: workout.date
                    )
                    .frame(height: 40)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 22)
            .padding(.bottom, 68)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: roundedCorners ? 20 : 0))
    }
}

#Preview {
    WorkoutCardView(workout: .mock)
        .padding()
        .background(Color.fitBg)
}
