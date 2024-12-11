import Foundation
import UserNotifications



struct NotificationHelper {
    
    ///// Requests notification permissions from the user
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
        
        // Optionally, log the current notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification Settings: \(settings)")
        }
    }
    
    /// Checks and sends notifications for upcoming birthdays
    static func checkAndSendNotifications(for birthdays: [Birthday]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysLater = calendar.date(byAdding: .day, value: 7, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        print("Checking notifications for \(birthdays.count) birthdays.")
        
        for birthday in birthdays {
            if calendar.isDate(birthday.nextBirthday, inSameDayAs: today) {
                print("Notification should fire: Happy Birthday Today! for \(birthday.name).")
                scheduleNotification(
                    title: "🎉 Happy Birthday Today!",
                    message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) today!",
                    for: birthday
                )
            } else if calendar.isDate(birthday.nextBirthday, inSameDayAs: sevenDaysLater) {
                print("Notification should fire: Birthday in 7 Days! for \(birthday.name).")
                scheduleNotification(
                    title: "🎉 Upcoming Birthday!",
                    message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) in 7 days!",
                    for: birthday
                )
            } else if calendar.isDate(birthday.nextBirthday, inSameDayAs: tomorrow) {
                print("Notification should fire: Birthday Tomorrow! for \(birthday.name).")
                scheduleNotification(
                    title: "🎉 Upcoming Birthday Tomorrow!",
                    message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) tomorrow!",
                    for: birthday
                )
            }
        }
    }
    
    /// Schedules a notification for a specific birthday
    static func scheduleNotification(title: String, message: String, for birthday: Birthday) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        // Unique identifier for each notification
        let identifier = "\(birthday.id.uuidString)-\(title)"
        print("Scheduling notification: \(title) for \(birthday.name) with ID \(identifier).")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // Temporary trigger for testing
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification scheduled successfully for \(birthday.name).")
            }
        }
    }
}
