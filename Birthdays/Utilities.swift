import Foundation
import WidgetKit

func saveBirthdays(_ birthdays: [Birthday]) {
    print("🚀 [DEBUG] saveBirthdays() called with \(birthdays.count) birthdays.")

    let suiteName = "group.com.bambina.birthdays" // Ensure this matches your App Group
    let sharedDefaults = UserDefaults(suiteName: suiteName)

    do {
        let encoded = try JSONEncoder().encode(birthdays)
        
        // Save to both standard UserDefaults and App Groups
        UserDefaults.standard.set(encoded, forKey: "birthdays")
        sharedDefaults?.set(encoded, forKey: "birthdays")
        
        print("✅ [DEBUG] Birthdays successfully saved: \(birthdays.map { $0.name })")
        
        // Force the widget to refresh
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 [DEBUG] Widget timeline reloaded.")

        // Check if NotificationHelper is being called
        print("📌 [DEBUG] Calling scheduleNotifications()...")
        NotificationHelper.scheduleNotifications(for: birthdays)
        print("📅 [DEBUG] Notifications scheduled for upcoming birthdays.")

    } catch {
        print("❌ [DEBUG] Failed to encode birthdays for saving: \(error.localizedDescription)")
    }

}

func loadBirthdays() -> [Birthday] {
    let suiteName = "group.com.bambina.birthdays"

    guard let sharedDefaults = UserDefaults(suiteName: suiteName) else {
        print("❌ [DEBUG] Failed to access UserDefaults for App Group: \(suiteName)")
        return []
    }

    guard let data = sharedDefaults.data(forKey: "birthdays") else {
        print("❌ [DEBUG] No birthday data found in UserDefaults.")
        return []
    }

    do {
        let decoded = try JSONDecoder().decode([Birthday].self, from: data)
        print("✅ [DEBUG] Successfully loaded \(decoded.count) birthdays from UserDefaults.")
        return decoded
    } catch {
        print("❌ [DEBUG] Failed to decode birthday data: \(error.localizedDescription)")
        return []
    }
}
func saveGroups(_ groups: [TagGroup]) {
    if let encoded = try? JSONEncoder().encode(groups) {
        UserDefaults.standard.set(encoded, forKey: "groups")
    }
}

func loadGroups() -> [TagGroup] {
    if let data = UserDefaults.standard.data(forKey: "groups"),
       let decoded = try? JSONDecoder().decode([TagGroup].self, from: data) {
        return decoded
    }
    return []
}
