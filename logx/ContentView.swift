import SwiftUI

struct ContentView: View {
    @Environment(HealthKitManager.self) private var healthKitManager

    var body: some View {
        NavigationStack {
            MainView()
        }
        .onAppear {
            Task {
                await healthKitManager.requestAuthorization()
                await NotificationManager.shared.requestPermission()
                await healthKitManager.enableBackgroundDelivery()
            }
        }
    }
}
