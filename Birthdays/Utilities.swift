import Foundation

func saveBirthdays(_ birthdays: [Birthday]) {
    if let encoded = try? JSONEncoder().encode(birthdays) {
        UserDefaults.standard.set(encoded, forKey: "birthdays")
        print("Birthdays saved: \(birthdays.map { $0.name })") // Log the saved birthdays
        NotificationHelper.scheduleUpcomingNotifications(for: birthdays) // Schedule notifications
    } else {
        print("Failed to encode birthdays for saving.")
    }
}

func loadBirthdays() -> [Birthday] {
    if let savedData = UserDefaults.standard.data(forKey: "birthdays"),
       let decoded = try? JSONDecoder().decode([Birthday].self, from: savedData) {
        return decoded
    }
    return []
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
