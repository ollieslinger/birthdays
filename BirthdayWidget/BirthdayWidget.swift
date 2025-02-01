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
        let entry = BirthdayEntry(date: Date(), upcomingBirthdays: loadUpcomingBirthdays())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
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

// MARK: - Main Entry View that Selects Subview Based on Family
struct BirthdayWidgetEntryView: View {
    var entry: BirthdayProvider.Entry
    var widgetFamily: WidgetFamily
    
    var body: some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                BirthdayWidgetSmallView(entry: entry)
            case .systemMedium:
                BirthdayWidgetMediumView(entry: entry)
            case .systemLarge:
                BirthdayWidgetLargeView(entry: entry)
            @unknown default:
                BirthdayWidgetSmallView(entry: entry)
            }
        }
    }
}

// MARK: - Small Widget View
struct BirthdayWidgetSmallView: View {
    var entry: BirthdayProvider.Entry

    var body: some View {
         VStack(alignment: .leading, spacing: 4) {
             if entry.upcomingBirthdays.isEmpty {
                 emptyStateView
             } else {
                 headerView
                 birthdayRow(for: entry.upcomingBirthdays.first!)
             }
         }
         .padding(8)
         .containerBackground(for: .widget) { Color.white }
    }
    
    private var headerView: some View {
         HStack(spacing: 4) {
              Image(systemName: "gift.fill")
                 .foregroundColor(.orange)
                 .font(.system(size: 18))
              Text("Birthdays")
                 .font(.custom("Bicyclette-Bold", size: 16))
                 .foregroundColor(.black)
              Spacer()
         }
         .padding(.bottom, 4)
    }
    
    private func birthdayRow(for birthday: Birthday) -> some View {
         HStack(spacing: 4) {
              VStack(alignment: .leading, spacing: 2) {
                  Text(birthday.name)
                      .font(.custom("Bicyclette-Bold", size: 14))
                      .foregroundColor(.black)
                  Text("\(birthday.daysUntilNextBirthday) days left")
                      .font(.custom("Bicyclette-Regular", size: 12))
                      .foregroundColor(.gray)
              }
              Spacer()
              Image(systemName: "calendar.circle.fill")
                  .foregroundColor(.orange)
                  .font(.system(size: 18))
         }
    }
    
    private var emptyStateView: some View {
         VStack(spacing: 4) {
             Image(systemName: "calendar.badge.plus")
                 .resizable()
                 .scaledToFit()
                 .frame(width: 50, height: 50)
                 .foregroundColor(.gray)
             Text("No birthdays")
                 .font(.custom("Bicyclette-Bold", size: 14))
                 .foregroundColor(.gray)
         }
         .frame(maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Medium Widget View
struct BirthdayWidgetMediumView: View {
    var entry: BirthdayProvider.Entry

    var body: some View {
         VStack(alignment: .leading, spacing: 6) {
             if entry.upcomingBirthdays.isEmpty {
                 emptyStateView
             } else {
                 headerView
                 ForEach(entry.upcomingBirthdays.prefix(2), id: \.id) { birthday in
                     birthdayRow(for: birthday)
                 }
             }
         }
         .padding(12)
         .containerBackground(for: .widget) { Color.white }
    }
    
    private var headerView: some View {
         HStack(spacing: 4) {
              Image(systemName: "gift.fill")
                 .foregroundColor(.orange)
                 .font(.system(size: 20))
              Text("Upcoming Birthdays")
                 .font(.custom("Bicyclette-Bold", size: 18))
                 .foregroundColor(.black)
              Spacer()
         }
         .padding(.bottom, 6)
    }
    
    private func birthdayRow(for birthday: Birthday) -> some View {
         HStack(spacing: 6) {
              VStack(alignment: .leading, spacing: 2) {
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
                  .font(.system(size: 20))
         }
    }
    
    private var emptyStateView: some View {
         VStack(spacing: 6) {
             Image(systemName: "calendar.badge.plus")
                 .resizable()
                 .scaledToFit()
                 .frame(width: 60, height: 60)
                 .foregroundColor(.gray)
             Text("No birthdays yet!")
                 .font(.custom("Bicyclette-Bold", size: 16))
                 .foregroundColor(.gray)
         }
         .frame(maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Large Widget View
struct BirthdayWidgetLargeView: View {
    var entry: BirthdayProvider.Entry

    var body: some View {
         VStack(alignment: .leading, spacing: 8) {
             if entry.upcomingBirthdays.isEmpty {
                 emptyStateView
             } else {
                 headerView
                 ForEach(entry.upcomingBirthdays.prefix(3), id: \.id) { birthday in
                     birthdayRow(for: birthday)
                 }
             }
         }
         .padding(16)
         .containerBackground(for: .widget) { Color.white }
    }
    
    private var headerView: some View {
         HStack(spacing: 4) {
              Image(systemName: "gift.fill")
                 .foregroundColor(.orange)
                 .font(.system(size: 22))
              Text("Upcoming Birthdays")
                 .font(.custom("Bicyclette-Bold", size: 20))
                 .foregroundColor(.black)
              Spacer()
         }
         .padding(.bottom, 8)
    }
    
    private func birthdayRow(for birthday: Birthday) -> some View {
         HStack(spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                  Text(birthday.name)
                      .font(.custom("Bicyclette-Bold", size: 18))
                      .foregroundColor(.black)
                  Text("\(birthday.daysUntilNextBirthday) days left")
                      .font(.custom("Bicyclette-Regular", size: 16))
                      .foregroundColor(.gray)
              }
              Spacer()
              Image(systemName: "calendar.circle.fill")
                  .foregroundColor(.orange)
                  .font(.system(size: 22))
         }
    }
    
    private var emptyStateView: some View {
         VStack(spacing: 8) {
             Image(systemName: "calendar.badge.plus")
                 .resizable()
                 .scaledToFit()
                 .frame(width: 70, height: 70)
                 .foregroundColor(.gray)
             Text("No birthdays yet!")
                 .font(.custom("Bicyclette-Bold", size: 18))
                 .foregroundColor(.gray)
         }
         .frame(maxHeight: .infinity, alignment: .center)
    }
}
