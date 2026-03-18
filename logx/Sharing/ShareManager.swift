import SwiftUI
import Photos

struct ShareManager {

    @MainActor
    static func render<V: View>(view: V) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = false
        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData() else { return nil }
        return UIImage(data: pngData)
    }

    @MainActor
    static func saveToPhotos<V: View>(view: V, transparent: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = false

        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData(),
              let pngImage = UIImage(data: pngData) else {
            completion?(false)
            return
        }

        Task.detached {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized else {
                    DispatchQueue.main.async { completion?(false) }
                    return
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: pngImage)
                }) { success, _ in
                    DispatchQueue.main.async {
                        completion?(success)
                    }
                }
            }
        }
    }
}
