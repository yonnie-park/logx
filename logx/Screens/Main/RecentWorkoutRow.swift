import SwiftUI

struct RecentWorkoutRow: View {
    let workout: WorkoutModel
    var onDelete: (() -> Void)? = nil

    @State private var offset: CGFloat = 0
    @State private var dragStart: CGFloat = 0
    @State private var showingDeleteConfirm = false

    private let deleteWidth: CGFloat = 80

    private var canSwipe: Bool { workout.isManual && onDelete != nil }

    var body: some View {
        ZStack(alignment: .trailing) {
            if canSwipe {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.fitRed)

                Button {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.fitWhite)
                        .frame(width: deleteWidth, height: 76)
                        .contentShape(Rectangle())
                }
                .accessibilityIdentifier("delete-workout-\(workout.id.uuidString)")
                .accessibilityLabel("delete workout")
                .opacity(offset < -8 ? 1 : 0)
            }

            Group {
                if canSwipe {
                    cardContent
                        .offset(x: offset)
                        .highPriorityGesture(dragGesture)
                } else {
                    cardContent
                }
            }
        }
        .confirmationDialog(
            "delete this workout?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("delete", role: .destructive) {
                withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
                dragStart = 0
                onDelete?()
            }
            Button("cancel", role: .cancel) {
                withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
                dragStart = 0
            }
        }
    }

    private var cardContent: some View {
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

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                let proposed = dragStart + value.translation.width
                offset = min(0, max(-deleteWidth, proposed))
            }
            .onEnded { _ in
                let target: CGFloat = offset < -deleteWidth / 2 ? -deleteWidth : 0
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    offset = target
                }
                dragStart = target
            }
    }
}
