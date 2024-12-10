import UserNotifications

struct NotificationHelper {
    /// Requests notification permissions from the user
    static func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            } else if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification Settings: \(settings)")
        }
    }
}

func scheduleNotification(for birthday: Birthday, at time: Date) {
    let notificationTimes: [(title: String, daysBefore: Int)] = [
        ("Upcoming Birthday in 7 Days!", 7),
        ("Upcoming Birthday Tomorrow!", 1),
        ("Happy Birthday Today!", 0)
    ]

    for notification in notificationTimes {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = "\(birthday.name) turns \(birthday.ageAtNextBirthday) on \(birthday.nextBirthdayFormatted)."
        content.sound = .default

        // Combine the notification time with the calculated trigger date
        let triggerDate = Calendar.current.date(byAdding: .day, value: -notification.daysBefore, to: birthday.nextBirthday) ?? birthday.nextBirthday
        let triggerTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        triggerComponents.hour = triggerTimeComponents.hour
        triggerComponents.minute = triggerTimeComponents.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        // Unique identifier for each notification
        let request = UNNotificationRequest(identifier: "\(birthday.id.uuidString)-\(notification.daysBefore)", content: content, trigger: trigger)

        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled: \(notification.title) for \(birthday.name) on \(triggerDate).")
            }
        }
    }
}
