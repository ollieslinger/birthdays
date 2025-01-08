import WidgetKit
import SwiftUI
import Foundation

// MARK: - Timeline Entry Model
struct BirthdayEntry: TimelineEntry {
    let date: Date
    let upcomingBirthdays: [Birthday]
}

// MARK: - Timeline Provider
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

// MARK: - Load Upcoming Birthdays from UserDefaults
func loadUpcomingBirthdays() -> [Birthday] {
    let suiteName = "group.com.bambina.birthdays"
    let sharedDefaults = UserDefaults(suiteName: suiteName)

    guard let sharedDefaults = sharedDefaults else {
        print("❌ [DEBUG] UserDefaults could not be accessed for App Group: \(suiteName)")
        return []
    }

    guard let data = sharedDefaults.data(forKey: "birthdays") else {
        print("❌ [DEBUG] No birthday data found in UserDefaults.")
        return []
    }

    do {
        let decoded = try JSONDecoder().decode([Birthday].self, from: data)
        
        print("✅ [DEBUG] Successfully loaded \(decoded.count) birthdays from UserDefaults.")

        let today = Calendar.current.startOfDay(for: Date())
        let upcomingBirthdays = decoded
            .filter { $0.nextBirthday >= today }
            .sorted { $0.nextBirthday < $1.nextBirthday }
            .prefix(3)
            .map { $0 }
        
        if upcomingBirthdays.isEmpty {
            print("⚠️ [DEBUG] No upcoming birthdays found.")
        } else {
            print("🎉 [DEBUG] Next birthdays:")
            for birthday in upcomingBirthdays {
                print("- \(birthday.name) (in \(birthday.daysUntilNextBirthday) days)")
            }
        }

        return Array(upcomingBirthdays)

    } catch {
        print("❌ [DEBUG] Failed to decode birthday data: \(error.localizedDescription)")
        return []
    }
}
// MARK: - Birthday Widget Definition
struct BirthdayWidget: Widget {
    let kind: String = "BirthdayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BirthdayProvider()) { entry in
            BirthdayWidgetContainer(entry: entry)
        }
        .configurationDisplayName("Upcoming Birthdays")
        .description("Displays the next upcoming birthdays.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Container
struct BirthdayWidgetContainer: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: BirthdayProvider.Entry

    var body: some View {
        BirthdayWidgetEntryView(entry: entry, widgetFamily: widgetFamily)
    }
}

// MARK: - Widget UI
struct BirthdayWidgetEntryView: View {
    var entry: BirthdayProvider.Entry
    var widgetFamily: WidgetFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if entry.upcomingBirthdays.isEmpty {
                emptyStateView
            } else {
                headerView
                birthdayListView
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.white
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Image(systemName: "gift.fill")
                .foregroundColor(.orange)
                .font(.title2)
            Text("🎉 Upcoming Birthdays")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.bottom, 6)
    }
    
    // MARK: - Birthday List View
    private var birthdayListView: some View {
        ForEach(entry.upcomingBirthdays.prefix(widgetFamily == .systemSmall ? 1 : 3), id: \.id) { birthday in
            HStack {
                VStack(alignment: .leading) {
                    Text(birthday.name)
                        .font(.custom("Bicyclette-Bold", size: 16))
                        .foregroundColor(.black)
                    Text("\(birthday.daysUntilNextBirthday) days left")
                        .font(.custom("Bicyclette-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "calendar.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .padding()
            
            Text("No birthdays yet!")
                .font(.custom("Bicyclette-Bold", size: 16))
                .foregroundColor(.gray)
            
            Button(action: {
                // Open the app when tapped
            }) {
                Text("Add a Birthday")
                    .font(.custom("Bicyclette-Bold", size: 14))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.top, 20)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
