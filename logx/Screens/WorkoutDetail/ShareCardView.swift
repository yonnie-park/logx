import SwiftUI

struct ShareCardView: View {
    let workout: WorkoutModel
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showShareSheet = false
    @State private var renderedCard: UIImage? = nil
    @State private var showSavedAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.fitBg.ignoresSafeArea()

            VStack(spacing: 24) {

                // Handle bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.fitWhite.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                // Card preview
                WorkoutCardView(workout: workout, backgroundImage: selectedImage)
                    .padding(.horizontal, 24)

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
        
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()  // 추가
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

    @MainActor
    private func renderAndSave() {
        let transparentCard = WorkoutCardView(
            workout: workout,
            backgroundImage: selectedImage,
            isTransparent: selectedImage == nil
        )
        ShareManager.saveToPhotos(view: transparentCard, transparent: selectedImage == nil) { success in
            if success { showSavedAlert = true }
        }
    }
}
