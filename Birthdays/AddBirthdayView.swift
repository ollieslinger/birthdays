import SwiftUI

struct AddBirthdayView: View {
    @Binding var isAddingBirthday: Bool
    @Binding var birthdays: [Birthday]

    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter name", text: $name)
                }
                Section(header: Text("Date of Birth")) {
                    DatePicker("Select date", selection: $birthDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Birthday")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isAddingBirthday = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if name.isEmpty {
                            showAlert = true
                        } else {
                            addBirthday()
                            isAddingBirthday = false
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Entry"), message: Text("Name cannot be empty."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addBirthday() {
        let newBirthday = Birthday(id: UUID(), name: name, birthDate: birthDate, giftIdeas: [])
        birthdays.append(newBirthday) // Add to the list
        saveBirthdays() // Save to UserDefaults
        scheduleNotification(for: newBirthday) // Schedule a notification
        isAddingBirthday = false // Close the modal
    }

    private func saveBirthdays() {
        if let encoded = try? JSONEncoder().encode(birthdays) {
            UserDefaults.standard.set(encoded, forKey: "birthdays")
        }
    }
}
