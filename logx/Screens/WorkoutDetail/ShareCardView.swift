import SwiftUI

struct ShareCardView: View {
    let workout: WorkoutModel
    @State private var selectedImage: UIImage? = nil
    @State private var pickedImage: UIImage? = nil
    @State private var cropTarget: CropTarget? = nil
    @State private var format: CardFormat = .post
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showShareSheet = false
    @State private var renderedCard: UIImage? = nil
    @State private var showSavedAlert = false
    @Environment(\.dismiss) var dismiss

    struct CropTarget: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    var body: some View {
        ZStack {
            Color.fitBg.ignoresSafeArea()

            VStack(spacing: 24) {

                // Handle bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.fitWhite.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                // Format toggle
                HStack(spacing: 6) {
                    ForEach(CardFormat.allCases) { f in
                        Button {
                            if format != f {
                                format = f
                                selectedImage = nil
                            }
                        } label: {
                            Text(f.label)
                                .font(.a2zBold(size: 13))
                                .foregroundColor(format == f ? .fitBg : .fitWhite.opacity(0.7))
                                .padding(.horizontal, 22)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(format == f ? Color.fitWhite : Color.clear)
                                )
                        }
                    }
                }
                .padding(4)
                .background(
                    Capsule().fill(Color.fitBgBtn)
                )
                .overlay(
                    Capsule().stroke(Color.fitWhite.opacity(0.15), lineWidth: 1)
                )

                // Card preview (scaled to fit available space)
                GeometryReader { geo in
                    WorkoutCardView(
                        workout: workout,
                        backgroundImage: selectedImage,
                        format: format
                    )
                    .scaleEffect(
                        min(
                            (geo.size.width - 48) / (UIScreen.main.bounds.width - 48),
                            geo.size.height / ((UIScreen.main.bounds.width - 48) / format.aspectRatio)
                        ),
                        anchor: .center
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }

                // Gallery / Camera buttons
                HStack(spacing: 10) {
                                    // Album button
                                    Button {
                                        showImagePicker = true
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("ALBUM")
                                                .font(.a2zBold(size: 13))
                                        }
                                        .foregroundColor(.fitText)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .background(Capsule().fill(Color.fitBgBtn))
                                    }
                                    .accessibilityIdentifier("action-album")
                                    .accessibilityLabel("Choose from album")

                                    // Camera button (icon only)
                                    Button {
                                        showCamera = true
                                    } label: {
                                        Image(systemName: "camera")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.fitText)
                                            .frame(width: 52, height: 52)
                                            .background(Capsule().fill(Color.fitBgBtn))
                                    }
                                    .accessibilityIdentifier("action-camera")
                                    .accessibilityLabel("Take photo")

                                    // Save button
                                    Button {
                                        renderAndSave()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.down")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("SAVE")
                                                .font(.a2zBold(size: 13))
                                        }
                                        .foregroundColor(.fitText)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .background(Capsule().fill(Color.fitBgBtn))
                                    }
                                    .accessibilityIdentifier("action-save")
                                    .accessibilityLabel("Save to photos")
                                }
                                .padding(.horizontal, 24)

                                Spacer()
                            }
                        }
        
        .sheet(isPresented: $showImagePicker, onDismiss: handlePickerDismiss) {
            ImagePicker(image: $pickedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera, onDismiss: handlePickerDismiss) {
            ImagePicker(image: $pickedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $cropTarget) { target in
            ImageCropView(
                image: target.image,
                aspectRatio: format.aspectRatio,
                onCrop: { cropped in
                    selectedImage = cropped
                    cropTarget = nil
                },
                onCancel: {
                    cropTarget = nil
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = renderedCard {
                ShareSheet(items: [img])
            }
        }
        .alert("saved to photos!", isPresented: $showSavedAlert) {
            Button("ok") {
                showSavedAlert = false
            }
        }
    }

    private func handlePickerDismiss() {
        guard let img = pickedImage else { return }
        pickedImage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            cropTarget = CropTarget(image: img)
        }
    }

    @MainActor
    private func renderAndSave() {
        let transparentCard = WorkoutCardView(
            workout: workout,
            backgroundImage: selectedImage,
            isTransparent: selectedImage == nil,
            roundedCorners: false,
            format: format
        )
        ShareManager.saveToPhotos(view: transparentCard, transparent: selectedImage == nil) { success in
            if success { showSavedAlert = true }
        }
    }
}
