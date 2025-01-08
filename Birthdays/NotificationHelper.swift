import Foundation
import UserNotifications

struct NotificationHelper {
    
    /// Requests notification permissions from the user
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
        
        // Log the current notification settings
        center.getNotificationSettings { settings in
            print("📌 [DEBUG] Notification Settings: \(settings)")
        }
    }
    
    static func scheduleNotifications(for birthdays: [Birthday]) {
        print("🚀 [DEBUG] scheduleNotifications() called with \(birthdays.count) birthdays.")
        
        let center = UNUserNotificationCenter.current()
        
        // Remove all existing notifications
        center.removeAllPendingNotificationRequests()
        print("🗑 [DEBUG] Removed all pending notifications.")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Retrieve the notification time directly as a Date.
        guard let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date else {
            print("❌ [DEBUG] No notification time set, skipping scheduling.")
            return
        }
        
        var scheduledNotifications: [String] = []
        
        for birthday in birthdays {
            // Get the nextBirthday and normalize it to the start of the day.
            let nextBirthday = birthday.nextBirthday
            let normalizedNextBirthday = calendar.startOfDay(for: nextBirthday)
            let daysUntil = calendar.dateComponents([.day], from: today, to: normalizedNextBirthday).day ?? 0
            
            // Log out the details for debugging.
            print("🕒 [DEBUG] \(birthday.name)'s nextBirthday: \(nextBirthday) (normalized: \(normalizedNextBirthday)), daysUntil: \(daysUntil)")
            
            var title: String?
            var message: String?
            var identifier: String?
            
            if daysUntil == 0 {
                title = "🎉 Happy Birthday Today!"
                message = "\(birthday.name) turns \(birthday.ageAtNextBirthday) today!"
                identifier = "\(birthday.id.uuidString)-today"
            } else if daysUntil == 1 {
                title = "🎉 Birthday Tomorrow!"
                message = "\(birthday.name) turns \(birthday.ageAtNextBirthday) tomorrow!"
                identifier = "\(birthday.id.uuidString)-tomorrow"
            } else if daysUntil == 7 {
                title = "🎉 Birthday in 7 Days!"
                message = "\(birthday.name) turns \(birthday.ageAtNextBirthday) in 7 days!"
                identifier = "\(birthday.id.uuidString)-week"
            }
            
            if let title = title, let message = message, let identifier = identifier {
                // Calculate the notification date by adding the daysUntil to today's start.
                let notificationDate = today
                if let triggerDate = combineDateAndTime(date: notificationDate, time: notificationTime) {
                    print("✅ [DEBUG] Scheduling notification: \(title) for \(birthday.name) at \(triggerDate)")
                    scheduleNotification(title: title, message: message, identifier: identifier, triggerDate: triggerDate)
                    scheduledNotifications.append(identifier)
                }
            }
        }
        
        // Debug: Log all scheduled notifications
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
    
    static func scheduleNotification(title: String, message: String, identifier: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
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
