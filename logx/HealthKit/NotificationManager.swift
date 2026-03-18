import UserNotifications
import HealthKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            #if DEBUG
            print("✅ 알림 권한 획득")
            #endif
        } catch {
            #if DEBUG
            print("❌ Notification 권한 에러: \(error)")
            #endif
        }
    }

    func sendWorkoutNotification(type: String, duration: TimeInterval, kcal: Int, workoutId: UUID) async {
        let minutes = Int(duration / 60)
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("new workout recorded!", comment: "Notification title")
        let localizedType = NSLocalizedString(type, comment: "Workout type")
        content.body = String(format: NSLocalizedString("notification.body", comment: ""), localizedType, minutes, kcal)
        content.sound = .default
        content.userInfo = ["workoutId": workoutId.uuidString]

        let request = UNNotificationRequest(
            identifier: workoutId.uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            #if DEBUG
            print("✅ 알림 발송: \(type)")
            #endif
        } catch {
            #if DEBUG
            print("❌ 알림 에러: \(error)")
            #endif
        }
    }

    // 포그라운드에서도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
