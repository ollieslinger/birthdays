import Foundation

/// Represents a Birthday entry with details about the person and their birth date
struct Birthday: Identifiable, Codable {
    let id: UUID
    var name: String
    var birthDate: Date
    var giftIdeas: [Gift] // Stores gift ideas
    
    struct Gift: Identifiable, Codable {
        let id: UUID
        var name: String
        var link: String? // Optional link
        var isPurchased: Bool
    }
    
    init(id: UUID = UUID(), name: String, birthDate: Date, giftIdeas: [Gift] = []) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.giftIdeas = giftIdeas
    }
    
    var isAnyGiftsPurchased: Bool {
        giftIdeas.contains { $0.isPurchased }
    }
    var nextBirthday: Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var nextBirthdayComponents = calendar.dateComponents([.month, .day], from: birthDate)
        nextBirthdayComponents.year = currentYear
        
        let today = calendar.startOfDay(for: Date())
        let nextBirthdayThisYear = calendar.date(from: nextBirthdayComponents)!
        
        if nextBirthdayThisYear >= today {
            // If birthday is today or in the future
            return nextBirthdayThisYear
        } else {
            // Otherwise, it's in the next year
            nextBirthdayComponents.year = currentYear + 1
            return calendar.date(from: nextBirthdayComponents)!
        }
    }
    
    var lastBirthday: Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var lastBirthdayComponents = calendar.dateComponents([.month, .day], from: birthDate)
        lastBirthdayComponents.year = currentYear
        
        let today = calendar.startOfDay(for: Date())
        let lastBirthdayThisYear = calendar.date(from: lastBirthdayComponents)!
        
        if lastBirthdayThisYear < today {
            // If birthday already occurred this year
            return lastBirthdayThisYear
        } else {
            // Otherwise, it was last year
            lastBirthdayComponents.year = currentYear - 1
            return calendar.date(from: lastBirthdayComponents)!
        }
    }
    var ageAtNextBirthday: Int {
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: birthDate)
        let nextBirthdayYear = calendar.component(.year, from: nextBirthday)
        return nextBirthdayYear - birthYear
    }
    
    var ageAtLastBirthday: Int {
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: birthDate)
        let lastBirthdayYear = calendar.component(.year, from: lastBirthday)
        return lastBirthdayYear - birthYear
    }
    
    var nextBirthdayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: nextBirthday)
    }
    
    var lastBirthdayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: lastBirthday)
    }
    
    var daysUntilNextBirthday: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfNextBirthday = calendar.startOfDay(for: nextBirthday)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfNextBirthday)
        return (components.day ?? 0) // Add 1 to include the starting day
    }
}

struct TagGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var members: [UUID] // UUIDs of birthdays in this group

    init(id: UUID = UUID(), name: String, members: [UUID] = []) {
        self.id = id
        self.name = name
        self.members = members
    }
}
