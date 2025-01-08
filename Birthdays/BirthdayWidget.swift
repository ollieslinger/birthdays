import WidgetKit
import SwiftUI

// Entry Model for the Widget
struct BirthdayEntry: TimelineEntry {
    let date: Date
    let upcomingBirthdays: [Birthday]
}

// Timeline Provider
struct BirthdayProvider: TimelineProvider {
    func placeholder(in context: Context) -> BirthdayEntry {
        BirthdayEntry(date: Date(), upcomingBirthdays: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (BirthdayEntry) -> Void) {
        let entry = BirthdayEntry(date: Date(), upcomingBirthdays: loadUpcomingBirthdays())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BirthdayEntry>) -> Void) {
        let entries = [BirthdayEntry(date: Date(), upcomingBirthdays: loadUpcomingBirthdays())]
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

// Function to Load Birthdays
func loadUpcomingBirthdays() -> [Birthday] {
    guard let data = UserDefaults.standard.data(forKey: "birthdays"),
          let decoded = try? JSONDecoder().decode([Birthday].self, from: data) else {
        return []
    }
    
    let today = Calendar.current.startOfDay(for: Date())
    return decoded
        .filter { $0.nextBirthday >= today }
        .sorted { $0.nextBirthday < $1.nextBirthday }
        .prefix(3) // Get the next 3 birthdays
        .map { $0 }
}

struct BirthdayWidget: Widget {
    let kind: String = "BirthdayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BirthdayProvider()) { entry in
            BirthdayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Upcoming Birthdays")
        .description("Displays the next three upcoming birthdays.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
struct BirthdayWidgetEntryView: View {
    var entry: BirthdayProvider.Entry

    var body: some View {
        VStack {
            Text("Upcoming Birthdays")
                .font(.headline)
                .foregroundColor(.white)
            ForEach(entry.upcomingBirthdays, id: \.id) { birthday in
                Text("\(birthday.name) - \(birthday.daysUntilNextBirthday) days")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.orange)
        .widgetURL(URL(string: "birthdaysapp://open"))
    }
}
