import Foundation
import UserNotifications

struct NotificationHelper {
    
    /// Requests notification permissions from the user.
    static func requestPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ [DEBUG] Error requesting notification permissions: \(error)")
            } else if granted {
                print("✅ [DEBUG] Notification permissions granted.")
            } else {
                print("⚠️ [DEBUG] Notification permissions denied.")
            }
        }
        
        // Log the current notification settings.
        center.getNotificationSettings { settings in
            print("📌 [DEBUG] Notification Settings: \(settings)")
        }
    }
    
    /// Schedules three notifications for each birthday (7 days before, 1 day before, and on the day)
    /// for birthdays that occur within the next year.
    static func scheduleNotifications(for birthdays: [Birthday]) {
        print("🚀 [DEBUG] scheduleNotifications() called with \(birthdays.count) birthdays.")
        
        let center = UNUserNotificationCenter.current()
        
        // Remove all existing notifications.
        center.removeAllPendingNotificationRequests()
        print("🗑 [DEBUG] Removed all pending notifications.")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate the cutoff date one year from today.
        guard let oneMonthfromToday = calendar.date(byAdding: .month, value: 1, to: today) else {
            print("❌ [DEBUG] Unable to calculate one month from today.")
            return
        }
        
        // Retrieve the notification time from UserDefaults (or use the default notification time).
        let notificationTime = (UserDefaults.standard.object(forKey: "notificationTime") as? Date)
            ?? defaultNotificationTime()
        
        var scheduledNotifications: [String] = []
        
        // Offsets in days for the three notifications.
        let offsets = [-7, -1, 0]
        
        for birthday in birthdays {
            // Get the upcoming birthday date and normalize it to the start of the day.
            let nextBirthday = birthday.nextBirthday
            let normalizedBirthday = calendar.startOfDay(for: nextBirthday)
            
            for offset in offsets {
                // Compute the potential trigger date by adding the offset to the birthday.
                guard let adjustedDate = calendar.date(byAdding: .day, value: offset, to: normalizedBirthday),
                      let triggerDate = combineDateAndTime(date: adjustedDate, time: notificationTime)
                else {
                    print("❌ [DEBUG] Unable to compute trigger date for \(birthday.name) with offset \(offset)")
                    continue
                }
                
                // Only schedule notifications that are in the future and within the next year.
                if triggerDate < Date() || triggerDate > oneMonthfromToday {
                    print("ℹ️ [DEBUG] Skipping notification for \(birthday.name) with offset \(offset) because triggerDate (\(triggerDate)) is out of range.")
                    continue
                }
                
                var title: String
                var message: String
                
                // Set the title and message based on the offset.
                switch offset {
                case -7:
                    title = "🎉 Birthday in 7 Days!"
                    message = "\(birthday.name) turns \(birthday.ageAtNextBirthday) in 7 days!"
                case -1:
                    title = "🎉 Birthday Tomorrow!"
                    message = "\(birthday.name) turns \(birthday.ageAtNextBirthday) tomorrow!"
                case 0:
                    title = "🎉 Happy Birthday Today!"
                    message = "\(birthday.name) turns \(birthday.ageAtNextBirthday) today!"
                default:
                    continue
                }
                
                // Create a unique identifier using the birthday id and offset.
                let identifier = "\(birthday.id.uuidString)-\(offset)"
                
                print("✅ [DEBUG] Scheduling notification: \(title) for \(birthday.name) at \(triggerDate)")
                scheduleNotification(title: title, message: message, identifier: identifier, triggerDate: triggerDate)
                scheduledNotifications.append(identifier)
            }
        }
        
        // Debug: Log all scheduled notifications.
        center.getPendingNotificationRequests { requests in
            print("🔍 [DEBUG] \(requests.count) pending notifications:")
            for request in requests {
                print("- \(request.identifier): \(request.content.title)")
            }
            
            let requestIDs = requests.map { $0.identifier }
            for id in scheduledNotifications {
                if !requestIDs.contains(id) {
                    print("❌ [DEBUG] Notification \(id) was scheduled but is missing from pending requests!")
                }
            }
        }
    }
    
    /// Schedules a single notification with the given title, message, identifier, and trigger date.
    static func scheduleNotification(title: String, message: String, identifier: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        // Ensure that the custom sound file "partyhornnotification.wav" is added to your project bundle.
        content.sound = UNNotificationSound(named: UNNotificationSoundName("partyhornnotification.wav"))
        
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ [DEBUG] Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Combines a specific date and time into a single `Date` object.
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
        print("🕒 Combined date and time: \(combinedDate?.description ?? "Invalid Date")")
        return combinedDate
    }
    
    /// Provides a default notification time (9:00 AM).
    static func defaultNotificationTime() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
}
