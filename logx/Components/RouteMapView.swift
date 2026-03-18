import SwiftUI
import CoreLocation

struct RouteMapView: View {
    let coordinates: [CLLocationCoordinate2D]
    var lineColor: Color = .fitRed
    var lineWidth: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            if coordinates.count > 1 {
                routePath(in: geo.size)
                    .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            }
        }
    }

    private func routePath(in size: CGSize) -> Path {
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)

        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!

        let latRange = maxLat - minLat
        let lonRange = maxLon - minLon
        let range = max(latRange, lonRange)

        // Padding
        let padding: CGFloat = 16
        let drawWidth = size.width - padding * 2
        let drawHeight = size.height - padding * 2

        func point(for coord: CLLocationCoordinate2D) -> CGPoint {
            let x = range > 0
                ? padding + CGFloat((coord.longitude - minLon) / range) * drawWidth
                : size.width / 2
            // Flip latitude (higher lat = up)
            let y = range > 0
                ? padding + CGFloat((maxLat - coord.latitude) / range) * drawHeight
                : size.height / 2
            return CGPoint(x: x, y: y)
        }

        return Path { path in
            path.move(to: point(for: coordinates[0]))
            for coord in coordinates.dropFirst() {
                path.addLine(to: point(for: coord))
            }
        }
    }
}
