import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var birthdays: [Birthday]
    @Binding var parsedBirthdays: [Birthday]
    @Binding var showConfirmationPage: Bool
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() } // Ensure resource release

                do {
                    let contents = try String(contentsOf: url, encoding: .utf8)
                    print("File Contents:", contents) // Debugging
                    DispatchQueue.main.async {
                        self.parent.parsedBirthdays = self.parent.parseCSV(contents: contents)
                        print("Parsed Birthdays in DocumentPicker:", self.parent.parsedBirthdays) // Debugging
                        self.parent.showConfirmationPage = true
                    }
                } catch {
                    print("Failed to read CSV file: \(error.localizedDescription)")
                }
            } else {
                print("Failed to access the selected file.")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func parseCSV(contents: String) -> [Birthday] {
        let rows = contents.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n")
        print("Rows from CSV:", rows) // Debugging
        var birthdays: [Birthday] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Match your CSV format

        for (index, row) in rows.enumerated() {
            if index == 0 { continue } // Skip header
            let columns = row.split(separator: ",", omittingEmptySubsequences: false)
            print("Columns for row \(index):", columns) // Debugging
            if columns.count >= 2 {
                let name = String(columns[0])
                if let date = dateFormatter.date(from: String(columns[1])) {
                    let giftStrings = columns.count > 2 ? String(columns[2]).split(separator: ";").map(String.init) : []
                    let gifts = giftStrings.map { Birthday.Gift(id: UUID(), name: $0, isPurchased: false) }
                    let birthday = Birthday(id: UUID(), name: name, birthDate: date, giftIdeas: gifts)
                    birthdays.append(birthday)
                    print("Parsed Birthday:", birthday) // Debugging
                } else {
                    print("Date parsing failed for:", columns[1]) // Debugging
                }
            } else {
                print("Insufficient columns for row \(index):", columns) // Debugging
            }
        }
        print("Parsed Birthdays:", birthdays) // Debugging
        return birthdays
    }

    func body() -> some View {
        NavigationView {
            if showConfirmationPage {
                ImportConfirmationView(
                    parsedBirthdays: $parsedBirthdays,
                    onConfirm: { selectedBirthdays in
                        birthdays.append(contentsOf: selectedBirthdays)
                        saveBirthdays()
                        dismissAll()
                    },
                    onCancel: {
                        dismissAll()
                    }
                )
            }
        }
    }

    private func dismissAll() {
        DispatchQueue.main.async {
            presentationMode.wrappedValue.dismiss() // Dismiss DocumentPicker
        }
    }

    private func saveBirthdays() {
        if let encoded = try? JSONEncoder().encode(birthdays) {
            UserDefaults.standard.set(encoded, forKey: "birthdays")
        }
    }
}
