import SwiftUI

struct DonutChart: View {
    let slices: [DonutSlice]
    let totalSessions: Int

    private var total: Double {
        Double(slices.map(\.percentage).reduce(0, +))
    }

    var body: some View {
        ZStack {
            ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                DonutSliceShape(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index)
                )
                .stroke(slice.color, style: StrokeStyle(lineWidth: 16, lineCap: .butt))
            }

            VStack(spacing: 0) {
                Text("\(totalSessions)")
                    .font(.a2zBold(size: 36))
                    .foregroundColor(.fitText)
                Text("sessions")
                    .font(.system(size: 12))
                    .foregroundColor(.fitMuted)
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let preceding = slices.prefix(index).map { Double($0.percentage) }.reduce(0, +)
        return .degrees((preceding / total) * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let preceding = slices.prefix(index + 1).map { Double($0.percentage) }.reduce(0, +)
        return .degrees((preceding / total) * 360 - 90)
    }
}

struct DonutSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
    }
}
