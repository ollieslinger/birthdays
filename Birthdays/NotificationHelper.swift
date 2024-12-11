import Foundation
import UserNotifications

struct NotificationHelper {
    static func checkAndSendNotifications(for birthdays: [Birthday]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysLater = calendar.date(byAdding: .day, value: 7, to: today)!

        for birthday in birthdays {
            if calendar.isDate(birthday.nextBirthday, inSameDayAs: today) {
                scheduleNotification(
                    title: "🎉 Happy Birthday Today!",
                    message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) today!",
                    for: birthday
                )
            } else if calendar.isDate(birthday.nextBirthday, inSameDayAs: sevenDaysLater) {
                scheduleNotification(
                    title: "🎉 Upcoming Birthday!",
                    message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) in 7 days!",
                    for: birthday
                )
            } else if calendar.isDate(birthday.nextBirthday, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today)!) {
                scheduleNotification(
                    title: "🎉 Upcoming Birthday Tomorrow!",
                    message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) tomorrow!",
                    for: birthday
                )
            }
        }
    }

    static func scheduleNotification(title: String, message: String, for birthday: Birthday) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        // Set trigger for notification time
        if let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            var triggerDateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            let today = Calendar.current.startOfDay(for: Date())
            triggerDateComponents.year = Calendar.current.component(.year, from: today)
            triggerDateComponents.month = Calendar.current.component(.month, from: today)
            triggerDateComponents.day = Calendar.current.component(.day, from: today)

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

            let identifier = "\(birthday.id.uuidString)-\(title)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                } else {
                    print("Notification scheduled: \(title) for \(birthday.name) at \(triggerDateComponents).")
                }
            }
        }
    }
}
