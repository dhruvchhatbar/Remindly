import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            @unknown default:
                completion(false)
            }
        }
    }

    func scheduleNotification(id: String, title: String, body: String, at date: Date, completion: @escaping (Bool) -> Void) {
        requestAuthorizationIfNeeded { granted in
            guard granted else { completion(false); return }

            let content = UNMutableNotificationContent()
            content.title = title.isEmpty ? "Reminder" : title
            content.body = body.isEmpty ? "You have a reminder." : body
            content.sound = .default

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            dateComponents.second = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    completion(error == nil)
                }
            }
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }

    // Foreground presentation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}


