import SwiftUI

@main
struct LogXApp: App {
    @State private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitManager)
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification)
                ) { _ in
                    Task {
                        await healthKitManager.fetchWorkouts()
                    }
                }
        }
    }
}
