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
        print("📌 [DEBUG] App launched - Registering background tasks.")
        
        // Register the background refresh task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.birthdays.dailyNotificationCheck", using: nil) { task in
            self.handleBirthdayCheck(task: task as! BGAppRefreshTask)
        }
        
        scheduleAppRefresh() // Ensure a daily refresh is scheduled
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh() // Ensure daily notification check is scheduled
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.birthdays.dailyNotificationCheck")
        let calendar = Calendar.current
        let now = Date()
        
        // Retrieve the saved notification time (which is just a time-of-day)
        var notificationTime: Date?
        if let savedDate = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            let components = calendar.dateComponents([.hour, .minute], from: savedDate)
            // Combine the saved hour/minute with today's date
            notificationTime = calendar.date(bySettingHour: components.hour ?? 9,
                                             minute: components.minute ?? 0,
                                             second: 0,
                                             of: now)
            print("📌 [DEBUG] Retrieved and adjusted notification time: \(notificationTime!)")
        } else {
            print("❌ [DEBUG] notificationTime is nil! Using default value.")
            notificationTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)
        }
        
        // Determine the expected refresh time. If the computed time is already past today, schedule for tomorrow.
        var refreshTime = notificationTime!
        if refreshTime < now {
            refreshTime = calendar.date(byAdding: .day, value: 1, to: refreshTime)!
            print("📅 [DEBUG] Adjusted refreshTime to next day: \(refreshTime)")
        }
        // After computing refreshTime...
        let buffer: TimeInterval = -60 // 60 seconds earlier
        request.earliestBeginDate = refreshTime.addingTimeInterval(buffer)
        print("📌 [DEBUG] Background task will be scheduled with buffer at \(request.earliestBeginDate!)")
        
        // Check if a pending task is scheduled—and if its time is different than our new refresh time.
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            if let existingTask = requests.first(where: { $0.identifier == "com.birthdays.dailyNotificationCheck" }),
               let scheduledTime = existingTask.earliestBeginDate {
                
                let timeDifference = abs(scheduledTime.timeIntervalSince(refreshTime))
                // If the difference is more than 60 seconds, assume the user changed the time.
                if timeDifference > 60 {
                    print("🔄 [DEBUG] Existing task scheduled at \(scheduledTime) differs from expected \(refreshTime). Cancelling and rescheduling.")
                    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.birthdays.dailyNotificationCheck")
                } else {
                    print("⚠️ [DEBUG] Existing task is scheduled for \(scheduledTime) (within tolerance). Skipping rescheduling.")
                    return
                }
            }
            
            do {
                try BGTaskScheduler.shared.submit(request)
                print("✅ [DEBUG] Background task successfully scheduled for \(refreshTime)")
            } catch {
                print("❌ [DEBUG] Failed to schedule background task: \(error)")
            }
        }
    }
    
    func runImmediateBirthdayCheck() {
        print("🚀 [DEBUG] Running immediate birthday check.")
        
        DispatchQueue.global().async {
            let birthdays = loadBirthdays()
            print("📅 [DEBUG] Loaded \(birthdays.count) birthdays from storage.")
            
            if birthdays.isEmpty {
                print("⚠️ [DEBUG] No birthdays found, skipping notifications.")
            } else {
                NotificationHelper.scheduleNotifications(for: birthdays)
                print("📌 [DEBUG] Immediate birthday notification check completed.")
            }
        }
    }
    
    private func handleBirthdayCheck(task: BGAppRefreshTask) {
        let startTime = Date()
        print("🚀 [DEBUG] handleBirthdayCheck triggered at \(startTime)")
        
        // Immediately schedule the next refresh.
        scheduleAppRefresh()
        
        // Log the start of processing and then perform the birthday check asynchronously.
        DispatchQueue.global().async {
            let birthdays = loadBirthdays()
            print("📅 [DEBUG] Loaded \(birthdays.count) birthdays from storage at \(Date())")
            
            if birthdays.isEmpty {
                print("⚠️ [DEBUG] No birthdays found, skipping notifications at \(Date()).")
            } else {
                print("📌 [DEBUG] Scheduling notifications for birthdays at \(Date()).")
                NotificationHelper.scheduleNotifications(for: birthdays)
                print("📌 [DEBUG] Birthday notification check completed at \(Date()).")
            }
            
            task.setTaskCompleted(success: true)
            print("✅ [DEBUG] Background task marked as completed at \(Date()).")
        }
        
        task.expirationHandler = {
            print("⏳ [DEBUG] Background task expired before completion at \(Date()).")
            task.setTaskCompleted(success: false)
        }
    }
}

// This function can remain outside of AppDelegate.
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.absoluteString == "birthdaysapp://open" {
        // Navigate to the Birthdays list in your app
    }
    return true
}
