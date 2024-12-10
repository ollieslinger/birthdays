import UIKit
import SwiftUI
import UniformTypeIdentifiers

class CSVImportDelegate: NSObject, UIDocumentPickerDelegate {
    @Binding var birthdays: [Birthday]

    init(birthdays: Binding<[Birthday]>) {
        _birthdays = birthdays
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            importBirthdaysFromCSV(contents: contents)
        } catch {
            print("Failed to read CSV file: \(error.localizedDescription)")
        }
    }

    private func importBirthdaysFromCSV(contents: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Match your CSV's date format

        let rows = contents.split(separator: "\n")
        var importedBirthdays: [Birthday] = []

        for (index, row) in rows.enumerated() {
            if index == 0 { continue } // Skip header
            let columns = row.split(separator: ",", omittingEmptySubsequences: false)

            if columns.count >= 2 { // Minimum required columns: Name, BirthDate
                let name = String(columns[0])
                if let date = dateFormatter.date(from: String(columns[1])) {
                    let giftStrings = columns.count > 2 ? String(columns[2]).split(separator: ";").map(String.init) : []
                    let gifts = giftStrings.map { Birthday.Gift(id: UUID(), name: $0, isPurchased: false) }
                    let birthday = Birthday(id: UUID(), name: name, birthDate: date, giftIdeas: gifts)
                    importedBirthdays.append(birthday)
                } else {
                    print("Failed to parse date for row: \(row)")
                }
            } else {
                print("Skipping row due to insufficient columns: \(row)")
            }
        }

        DispatchQueue.main.async {
            self.birthdays.append(contentsOf: importedBirthdays)
            saveBirthdays(self.birthdays) // Call the global save function

            print("Successfully imported \(importedBirthdays.count) birthdays.")
        }
    }

}
