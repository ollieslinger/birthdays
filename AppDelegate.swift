import SwiftUI
import UIKit
import BackgroundTasks

struct AppDelegateKey: EnvironmentKey {
    static var defaultValue: AppDelegate? = nil
}

extension EnvironmentValues {
    var appDelegate: AppDelegate? {
        get { self[AppDelegateKey.self] }
        set { self[AppDelegateKey.self] = newValue }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.birthdays.dailyNotificationCheck", using: nil) { task in
            self.handleBirthdayCheck(task: task as! BGAppRefreshTask)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.birthdays.dailyNotificationCheck")
        
        // Get the saved notification time or use a default
        if let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            let calendar = Calendar.current
            let now = Date()
            
            // Calculate today's notification time
            var todayNotificationDate = calendar.startOfDay(for: now)
                .addingTimeInterval(notificationTime.timeIntervalSince(calendar.startOfDay(for: notificationTime)))
            print("Calculated notification time: \(todayNotificationDate)")
            
            // If the time has passed today, schedule for tomorrow
            if todayNotificationDate < now {
                todayNotificationDate = calendar.date(byAdding: .day, value: 1, to: todayNotificationDate)!
            }

            // Set the earliest begin date for the task
            request.earliestBeginDate = todayNotificationDate
            print("Scheduled notification check for \(todayNotificationDate)")
        } else {
            // Default: schedule for 24 hours later if no time is set
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 24)
            print("No notification time set. Scheduling for the default time (next day).")
        }

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task successfully scheduled.")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    private func handleBirthdayCheck(task: BGAppRefreshTask) {
        print("handleBirthdayCheck triggered.")

        scheduleAppRefresh() // Reschedule the task for the next day

        DispatchQueue.global().async {
            let birthdays = loadBirthdays() // Load birthdays from persistent storage
            print("Loaded \(birthdays.count) birthdays.")
            
            NotificationHelper.checkAndSendNotifications(for: birthdays)
            print("Birthday check completed.")
            
            task.setTaskCompleted(success: true) // Mark the task as completed
        }

        task.expirationHandler = {
            print("Background task expired.")
            task.setTaskCompleted(success: false)
        }
    }
}

