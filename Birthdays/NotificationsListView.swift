import UserNotifications
import SwiftUI

// Fetch all scheduled notifications
func fetchScheduledNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        completion(requests)
    }
}

struct NotificationsListView: View {
    @State private var notifications: [UNNotificationRequest] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("🔔 Notifications")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    clearAllNotifications()
                }) {
                    Text("Clear All")
                        .font(.custom("Bicyclette-Bold", size: 16))
                        .foregroundColor(notifications.isEmpty ? Color.gray : Color.red) // Text turns gray when disabled
                }
                .disabled(notifications.isEmpty) // Disable button if no notifications
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()
                .background(Color.gray)

            // Content Section
            if notifications.isEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "bell.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding()

                    Text("No scheduled notifications!")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(maxWidth: .infinity) // Allow full width
                .padding(.top, 40) // Add space from the top edge
            } else {
                List {
                    ForEach(sortedNotifications, id: \.identifier) { notification in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(notification.content.title)
                                .font(.custom("Bicyclette-Bold", size: 18))
                            Text(notification.content.body)
                                .font(.custom("Bicyclette-Regular", size: 14))
                                .foregroundColor(.gray)

                            if let trigger = notification.trigger as? UNCalendarNotificationTrigger,
                               let nextDate = trigger.nextTriggerDate() {
                                Text("Scheduled: \(nextDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .onDelete(perform: deleteNotification) // Enable swipe-to-delete
                }
                .listStyle(PlainListStyle())
            }

            Spacer() // Push content to the top
        }
        .onAppear(perform: loadNotifications)
        .background(Color.white)
    }

    // MARK: - Sorted Notifications
    private var sortedNotifications: [UNNotificationRequest] {
        notifications.sorted { first, second in
            guard let firstDate = (first.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate(),
                  let secondDate = (second.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() else {
                return false
            }
            return firstDate < secondDate
        }
    }

    // MARK: - Load Notifications
    private func loadNotifications() {
        fetchScheduledNotifications { requests in
            DispatchQueue.main.async {
                self.notifications = requests
            }
        }
    }

    // MARK: - Clear All Notifications
    private func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        loadNotifications()
    }

    // MARK: - Delete Individual Notification
    private func deleteNotification(at offsets: IndexSet) {
        let identifiersToDelete = offsets.map { sortedNotifications[$0].identifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToDelete)
        loadNotifications() // Refresh the list
    }
    
    // MARK: - Schedule Test Notification
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Test Notification"
        content.body = "This is a test notification to check if everything works fine."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("partyhornnotification.wav"))

        // Trigger the notification after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully.")
                loadNotifications() // Refresh the list
            }
        }
    }
}
