import SwiftUI
import UIKit

struct ImageCropView: View {
    let image: UIImage
    let aspectRatio: CGFloat
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var accumulatedScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let frame = cropFrame(in: geo.size)
            let base = baseImageSize(for: frame.size)
            let rawScale = max(1.0, accumulatedScale * scale)
            let currentScale = min(rawScale, 6.0)
            let maxDX = max(0, (base.width * currentScale - frame.width) / 2)
            let maxDY = max(0, (base.height * currentScale - frame.height) / 2)
            let rawOffset = CGSize(
                width: accumulatedOffset.width + offset.width,
                height: accumulatedOffset.height + offset.height
            )
            let currentOffset = CGSize(
                width: min(max(rawOffset.width, -maxDX), maxDX),
                height: min(max(rawOffset.height, -maxDY), maxDY)
            )

            ZStack {
                Color.fitBg.ignoresSafeArea()

                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: base.width, height: base.height)
                        .scaleEffect(currentScale)
                        .offset(currentOffset)
                }
                .frame(width: frame.width, height: frame.height)
                .clipped()

                Color.fitBg.opacity(0.75)
                    .mask(
                        ZStack {
                            Rectangle().fill(.white)
                            Rectangle()
                                .frame(width: frame.width, height: frame.height)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                        .ignoresSafeArea()
                    )
                    .allowsHitTesting(false)

                Rectangle()
                    .stroke(Color.fitWhite.opacity(0.8), lineWidth: 1)
                    .frame(width: frame.width, height: frame.height)
                    .allowsHitTesting(false)

                VStack {
                    HStack {
                        Button {
                            onCancel()
                        } label: {
                            Text("cancel")
                                .font(.a2zBold(size: 13))
                                .foregroundColor(.fitText)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color.fitBgBtn))
                        }
                        Spacer()
                        Button {
                            let cropped = renderCrop(
                                baseSize: base,
                                currentScale: currentScale,
                                currentOffset: currentOffset,
                                cropSize: frame.size
                            )
                            onCrop(cropped)
                        } label: {
                            Text("done")
                                .font(.a2zBold(size: 13))
                                .foregroundColor(.fitText)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color.fitBgBtn))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in scale = value }
                        .onEnded { _ in
                            let committed = max(1.0, min(accumulatedScale * scale, 6.0))
                            accumulatedScale = committed
                            scale = 1.0
                            let clampX = max(0, (base.width * committed - frame.width) / 2)
                            let clampY = max(0, (base.height * committed - frame.height) / 2)
                            accumulatedOffset.width = min(max(accumulatedOffset.width, -clampX), clampX)
                            accumulatedOffset.height = min(max(accumulatedOffset.height, -clampY), clampY)
                        },
                    DragGesture()
                        .onChanged { value in offset = value.translation }
                        .onEnded { _ in
                            let committed = max(1.0, min(accumulatedScale, 6.0))
                            let clampX = max(0, (base.width * committed - frame.width) / 2)
                            let clampY = max(0, (base.height * committed - frame.height) / 2)
                            let newX = accumulatedOffset.width + offset.width
                            let newY = accumulatedOffset.height + offset.height
                            accumulatedOffset.width = min(max(newX, -clampX), clampX)
                            accumulatedOffset.height = min(max(newY, -clampY), clampY)
                            offset = .zero
                        }
                )
            )
        }
    }

    private func cropFrame(in size: CGSize) -> CGRect {
        let maxW = size.width - 32
        let maxH = size.height - 160
        var w = maxW
        var h = w / aspectRatio
        if h > maxH {
            h = maxH
            w = h * aspectRatio
        }
        return CGRect(
            x: (size.width - w) / 2,
            y: (size.height - h) / 2,
            width: w,
            height: h
        )
    }

    private func baseImageSize(for cropSize: CGSize) -> CGSize {
        let imgAspect = image.size.width / max(image.size.height, 1)
        if imgAspect > aspectRatio {
            return CGSize(width: cropSize.height * imgAspect, height: cropSize.height)
        } else {
            return CGSize(width: cropSize.width, height: cropSize.width / imgAspect)
        }
    }

    private func renderCrop(
        baseSize: CGSize,
        currentScale: CGFloat,
        currentOffset: CGSize,
        cropSize: CGSize
    ) -> UIImage {
        let displayedW = baseSize.width * currentScale
        let displayedH = baseSize.height * currentScale
        guard displayedW > 0, displayedH > 0 else { return image }

        let pointsToPixels = image.size.width / displayedW

        let cropOriginXPts = (displayedW - cropSize.width) / 2 - currentOffset.width
        let cropOriginYPts = (displayedH - cropSize.height) / 2 - currentOffset.height

        let cropXPx = cropOriginXPts * pointsToPixels
        let cropYPx = cropOriginYPts * pointsToPixels
        let cropWPx = cropSize.width * pointsToPixels
        let cropHPx = cropSize.height * pointsToPixels

        let outputSize = CGSize(width: cropWPx, height: cropHPx)
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(
                x: -cropXPx,
                y: -cropYPx,
                width: image.size.width,
                height: image.size.height
            ))
        }
    }
}
