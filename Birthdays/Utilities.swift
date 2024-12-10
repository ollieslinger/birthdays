import Foundation

func saveBirthdays(_ birthdays: [Birthday]) {
    if let encoded = try? JSONEncoder().encode(birthdays) {
        UserDefaults.standard.set(encoded, forKey: "birthdays")
    }
}

func loadBirthdays() -> [Birthday] {
    if let savedData = UserDefaults.standard.data(forKey: "birthdays"),
       let decoded = try? JSONDecoder().decode([Birthday].self, from: savedData) {
        return decoded
    }
    return []
}
