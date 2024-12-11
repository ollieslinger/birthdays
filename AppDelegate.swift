import UIKit
import BackgroundTasks

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

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.birthdays.dailyNotificationCheck")
        // Schedule the task to run close to the notification time
        if let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            let todayNotificationDate = Calendar.current.startOfDay(for: Date())
                .addingTimeInterval(notificationTime.timeIntervalSince(Calendar.current.startOfDay(for: notificationTime)))
            request.earliestBeginDate = todayNotificationDate
        } else {
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 24) // Default: next day
        }

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled for notification check.")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    private func handleBirthdayCheck(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Reschedule the task for the next day

        // Perform birthday notification logic
        DispatchQueue.global().async {
            let birthdays = loadBirthdays() // Load birthdays from persistent storage
            NotificationHelper.checkAndSendNotifications(for: birthdays)
            task.setTaskCompleted(success: true) // Mark the task as completed
        }

        // Provide an expiration handler
        task.expirationHandler = {
            print("Background task expired.")
            task.setTaskCompleted(success: false)
        }
    }
}
