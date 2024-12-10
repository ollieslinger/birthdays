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

func scheduleNotification(for birthday: Birthday) {
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

        // Calculate the trigger date
        let triggerDate = Calendar.current.date(byAdding: .day, value: -notification.daysBefore, to: birthday.nextBirthday) ?? birthday.nextBirthday
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        // Use a unique identifier for each notification (e.g., ID + daysBefore)
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
