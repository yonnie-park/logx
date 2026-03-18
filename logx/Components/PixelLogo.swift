import SwiftUI

struct PixelLogo: View {
    var size: CGFloat = 48

    var body: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
