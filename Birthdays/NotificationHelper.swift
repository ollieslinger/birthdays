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

        // 1. Fetch all pending notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            var validIdentifiers = Set<String>()
            
            // 2. Iterate over the birthday list and schedule valid notifications
            var notificationsScheduled = 0
            
            for birthday in birthdays {
                let birthdayTodayIdentifier = "\(birthday.id.uuidString)-0"
                let birthdayTomorrowIdentifier = "\(birthday.id.uuidString)-1"
                let birthdaySevenDaysIdentifier = "\(birthday.id.uuidString)-7"
                
                // Check for birthdays today
                if calendar.isDate(birthday.nextBirthday, inSameDayAs: tomorrow) {
                    if let scheduledTime = combineDateAndTime(date: tomorrow, time: notificationTime) {
                        validIdentifiers.insert(birthdayTodayIdentifier)
                        print("Notification validated/scheduled: Birthday Today! for \(birthday.name).")
                        queueNotification(
                            title: "🎉 Happy Birthday Today!",
                            message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) today!",
                            for: birthday,
                            identifier: birthdayTodayIdentifier,
                            triggerDate: scheduledTime
                        )
                        notificationsScheduled += 1
                    }
                }
                
                // Check for birthdays tomorrow
                if calendar.isDate(birthday.nextBirthday, inSameDayAs: dayAfterTomorrow) {
                    if let scheduledTime = combineDateAndTime(date: tomorrow, time: notificationTime) {
                        validIdentifiers.insert(birthdayTomorrowIdentifier)
                        print("Notification validated/scheduled: Birthday Tomorrow! for \(birthday.name).")
                        queueNotification(
                            title: "🎉 Birthday Tomorrow!",
                            message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) tomorrow!",
                            for: birthday,
                            identifier: birthdayTomorrowIdentifier,
                            triggerDate: scheduledTime
                        )
                        notificationsScheduled += 1
                    }
                }
                
                // Check for birthdays in 7 days
                if calendar.isDate(birthday.nextBirthday, inSameDayAs: eightDaysLater) {
                    if let scheduledTime = combineDateAndTime(date: tomorrow, time: notificationTime) {
                        validIdentifiers.insert(birthdaySevenDaysIdentifier)
                        print("Notification validated/scheduled: Birthday in 7 Days! for \(birthday.name).")
                        queueNotification(
                            title: "🎉 Birthday in 7 Days!",
                            message: "\(birthday.name) turns \(birthday.ageAtNextBirthday) in 7 days!",
                            for: birthday,
                            identifier: birthdaySevenDaysIdentifier,
                            triggerDate: scheduledTime
                        )
                        notificationsScheduled += 1
                    }
                }
            }
            
            // 3. Remove invalid notifications
            let allIdentifiers = requests.map { $0.identifier }
            let invalidIdentifiers = allIdentifiers.filter { !validIdentifiers.contains($0) }

            if !invalidIdentifiers.isEmpty {
                print("Removing \(invalidIdentifiers.count) invalid notifications: \(invalidIdentifiers)")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: invalidIdentifiers)
            }

            print("\(notificationsScheduled) notifications validated and scheduled.")
        }
    }

    /// Queues a notification to fire at a specific date and time.
    static func queueNotification(
        title: String,
        message: String,
        for birthday: Birthday,
        identifier: String,
        triggerDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        // Set up a notification trigger for the specified date and time
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        print("Queuing notification: \(title) for \(birthday.name) at \(triggerDate) with ID \(identifier).")

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification queued successfully for \(birthday.name).")
            }
        }
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


}
