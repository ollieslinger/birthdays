import UserNotifications

func fetchScheduledNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        completion(requests)
    }
}

import SwiftUI
import UserNotifications

struct NotificationsListView: View {
    @State private var notifications: [UNNotificationRequest] = []

    var body: some View {
        VStack {
            // Header
            HStack {
                Text("🔔 Notifications")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                Spacer()
                Button("Clear All") {
                    clearAllNotifications()
                }
                .font(.custom("Bicyclette-Bold", size: 16))
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()
                .background(Color.gray)

            if notifications.isEmpty {
                VStack(alignment: .center) {
                    Text("No scheduled notifications!")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.gray)
                        .padding()
                    Spacer() // Ensures the text stays at the top
                }
                .frame(maxWidth: .infinity, alignment: .top)
            
            } else {
                List {
                    ForEach(sortedNotifications, id: \.identifier) { notification in
                        HStack {
                            VStack(alignment: .leading) {
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
                            Spacer()
                            Button(action: {
                                deleteNotification(identifier: notification.identifier)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
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
    private func deleteNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        loadNotifications() // Refresh the list
    }
}
