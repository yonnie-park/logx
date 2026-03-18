import SwiftUI

struct RecentWorkoutRow: View {
    let workout: WorkoutModel

    var body: some View {
        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
            HStack(spacing: 16) {

                WorkoutIcon(type: workout.type)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(workout.type))
                        .font(.a2zBold(size: 15))
                        .foregroundColor(.fitText)

                    Text(workout.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.fitMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.formattedDuration)
                        .font(.a2zBold(size: 15))
                        .foregroundColor(.fitText)

                    Text("\(workout.activeKcal) kcal")
                        .font(.system(size: 12))
                        .foregroundColor(.fitMuted)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.fitBgBtn)
            )
        }
        .accessibilityIdentifier("workout-row-\(workout.id.uuidString)")
        .accessibilityLabel("\(workout.type), \(workout.formattedDate)")
    }
}
