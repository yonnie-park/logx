import SwiftUI

struct HeartRateGraph: View {
    let samples: [HeartRateSample]
    let workoutStart: Date

    private var minBPM: Int { samples.map(\.bpm).min() ?? 0 }
    private var maxBPM: Int { samples.map(\.bpm).max() ?? 200 }
    private var bpmRange: Double { Double(maxBPM - minBPM) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {

                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<4) { i in
                        Spacer()
                        Rectangle()
                            .fill(Color.fitWhite.opacity(0.06))
                            .frame(height: 1)
                    }
                }

                // Graph line + fill
                if samples.count > 1 {
                    // Fill
                    heartRatePath(in: geo.size, filled: true)
                        .fill(
                            LinearGradient(
                                colors: [Color.fitRed.opacity(0.3), Color.fitRed.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Line
                    heartRatePath(in: geo.size, filled: false)
                        .stroke(Color.fitRed, lineWidth: 1)
                }

                // BPM labels
                VStack {
                    Text("\(maxBPM)")
                        .font(.system(size: 10))
                        .foregroundColor(.fitWhite.opacity(0.3))
                    Spacer()
                    Text("\(minBPM)")
                        .font(.system(size: 10))
                        .foregroundColor(.fitWhite.opacity(0.3))
                }
            }
        }
    }

    private func heartRatePath(in size: CGSize, filled: Bool) -> Path {
        Path { path in
            let points = samples.enumerated().map { i, sample -> CGPoint in
                let x = size.width * CGFloat(i) / CGFloat(samples.count - 1)
                let normalized = bpmRange > 0
                    ? CGFloat(sample.bpm - minBPM) / CGFloat(bpmRange)
                    : 0.5
                let y = size.height * (1 - normalized)
                return CGPoint(x: x, y: y)
            }

            path.move(to: points[0])
            for i in 1..<points.count {
                let prev = points[i - 1]
                let curr = points[i]
                let control1 = CGPoint(x: (prev.x + curr.x) / 2, y: prev.y)
                let control2 = CGPoint(x: (prev.x + curr.x) / 2, y: curr.y)
                path.addCurve(to: curr, control1: control1, control2: control2)
            }

            if filled {
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.closeSubpath()
            }
        }
    }
}

#Preview {
    HeartRateGraph(samples: HeartRateSample.mockSamples, workoutStart: Date())
        .frame(height: 140)
        .padding()
        .background(Color.fitBg)
}
