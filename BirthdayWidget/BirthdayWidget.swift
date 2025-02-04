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
        
        if upcomingBirthdays.isEmpty {
            print("⚠️ [DEBUG] No upcoming birthdays found.")
        } else {
            print("🎉 [DEBUG] Next birthdays:")
            for birthday in upcomingBirthdays {
                print("- \(birthday.name) (in \(birthday.daysUntilNextBirthday) days)")
            }
        }
        return upcomingBirthdays
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

// MARK: - Main Entry View that Selects Layout Based on Family
struct BirthdayWidgetEntryView: View {
    var entry: BirthdayProvider.Entry
    var widgetFamily: WidgetFamily
    
    /// Select the number of birthdays to show.
    private var rowsToShow: [Birthday] {
        switch widgetFamily {
        case .systemSmall:
            return Array(entry.upcomingBirthdays.prefix(1))
        case .systemMedium:
            return Array(entry.upcomingBirthdays.prefix(4))
        case .systemLarge:
            return Array(entry.upcomingBirthdays.prefix(10))
        @unknown default:
            return Array(entry.upcomingBirthdays.prefix(1))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            if rowsToShow.isEmpty {
                emptyStateView
            } else {
                if widgetFamily == .systemSmall {
                    // One column for small widget
                    ForEach(rowsToShow, id: \.id) { birthday in
                        BirthdayRowView(birthday: birthday)
                    }
                } else {
                    // Two columns for medium and large widgets.
                    let columns = [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(rowsToShow, id: \.id) { birthday in
                            BirthdayRowView(birthday: birthday)
                        }
                    }
                }
            }
        }
        .padding(widgetFamily == .systemSmall ? 4 : 8)
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

// MARK: - Reusable Birthday Row View
struct BirthdayRowView: View {
    var birthday: Birthday

    var body: some View {
        let isHighlight = birthday.daysUntilNextBirthday <= 7
        return ZStack {
            // Background card with shadow and border
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: cardShadowColor(for: birthday), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(cardBorderColor(for: birthday), lineWidth: 1)
                )
            // Content on top, aligned to the left.
            HStack(spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(birthday.name)
                        .font(.custom("Bicyclette-Bold", size: 14))
                        .foregroundColor(.black)
                        .lineLimit(1) // Allow up to two lines
                        .minimumScaleFactor(0.5) // Shrink text down to 50% of its original size if needed.
                    Text("\(birthday.daysUntilNextBirthday) days left")
                        .font(.custom("Bicyclette-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding(8)
        }
    }
}
// MARK: - Helper Functions for Border and Shadow
func cardShadowColor(for birthday: Birthday) -> Color {
    return birthday.daysUntilNextBirthday <= 7 ? Color.orange.opacity(0.5) : Color.gray.opacity(0.3)
}

func cardBorderColor(for birthday: Birthday) -> Color {
    return birthday.daysUntilNextBirthday <= 7 ? Color.orange : Color.gray
}

// MARK: - Widget Previews
struct BirthdayWidget_Previews: PreviewProvider {
    static var sampleBirthday: Birthday {
        // Create a sample birthday. Adjust the birthDate so that nextBirthday falls in the future.
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        return Birthday(id: UUID(), name: "Pete", birthDate: birthDate)
    }
    
    static var sampleEntry: BirthdayEntry {
        BirthdayEntry(date: Date(), upcomingBirthdays: [sampleBirthday, sampleBirthday, sampleBirthday, sampleBirthday, sampleBirthday])
    }
    
    static var previews: some View {
        Group {
            BirthdayWidgetEntryView(entry: sampleEntry, widgetFamily: .systemSmall)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            BirthdayWidgetEntryView(entry: sampleEntry, widgetFamily: .systemMedium)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            BirthdayWidgetEntryView(entry: sampleEntry, widgetFamily: .systemLarge)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
