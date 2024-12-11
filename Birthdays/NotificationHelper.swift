import Foundation
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
        
        // Optionally, log the current notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification Settings: \(settings)")
        }
    }
    
    /// Schedules notifications for upcoming birthdays (today + 1, tomorrow + 1, and 7 days + 1).
    static func scheduleUpcomingNotifications(for birthdays: [Birthday]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        let eightDaysLater = calendar.date(byAdding: .day, value: 8, to: today)!

        print("Checking for birthdays to schedule notifications...")

        // Retrieve user-defined notification time
        guard let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date else {
            print("Notification time not set. Using default time: 9:00 AM.")
            return
        }
        
        var notificationsScheduled = 0
        
        for birthday in birthdays {
            if calendar.isDate(birthday.nextBirthday, inSameDayAs: dayAfterTomorrow) {
                // Combine tomorrow's date with user-defined notification time
                if let scheduledTime = combineDateAndTime(date: tomorrow, time: notificationTime) {
                    print("Notification scheduled: Birthday Tomorrow! for \(birthday.name).")
                    queueNotification(
                        title: "🎉 Birthday Tomorrow!",
                        message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) tomorrow!",
                        for: birthday,
                        triggerDate: scheduledTime
                    )
                    notificationsScheduled += 1
                }
            } else if calendar.isDate(birthday.nextBirthday, inSameDayAs: eightDaysLater) {
                // Combine tomorrow's date with user-defined notification time
                if let scheduledTime = combineDateAndTime(date: tomorrow, time: notificationTime) {
                    print("Notification scheduled: Birthday in 7 Days! for \(birthday.name).")
                    queueNotification(
                        title: "🎉 Birthday in 7 Days!",
                        message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) in 7 days!",
                        for: birthday,
                        triggerDate: scheduledTime
                    )
                    notificationsScheduled += 1
                }
            }
        }
        
        print("\(notificationsScheduled) notifications scheduled.")
    }

    /// Combines a specific date and time into a single `Date` object
    static func combineDateAndTime(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        let combinedDate = calendar.date(from: combinedComponents)
        print("Combined date and time: \(combinedDate?.description ?? "Invalid Date")")
        return combinedDate
    }

    /// Queues a notification to fire at a specific date and time.
    static func queueNotification(title: String, message: String, for birthday: Birthday, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        // Set up a notification trigger for the specified date and time
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        // Unique identifier for the notification
        let identifier = "\(birthday.id.uuidString)-\(title)"
        print("Queuing notification: \(title) for \(birthday.name) at \(triggerDate).")

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification queued successfully for \(birthday.name).")
            }
        }
    }
}
