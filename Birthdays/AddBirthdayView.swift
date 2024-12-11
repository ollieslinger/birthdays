import SwiftUI

struct AddBirthdayView: View {
    @Binding var isAddingBirthday: Bool
    @Binding var birthdays: [Birthday]

    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("🎉 Add Birthday")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)

                Divider()
                    .background(Color.gray)

                // Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)

                        TextField("Enter name", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    }

                    // Date Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)

                        DatePicker("Select date", selection: $birthDate, displayedComponents: .date)
                            .labelsHidden()
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Save Button
                Button(action: {
                    if name.isEmpty {
                        showAlert = true
                    } else {
                        addBirthday()
                        isAddingBirthday = false
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Save Birthday")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .background(Color.white)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Entry"), message: Text("Name cannot be empty."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addBirthday() {
        let newBirthday = Birthday(id: UUID(), name: name, birthDate: birthDate, giftIdeas: [])
        birthdays.append(newBirthday) // Add to the list
        saveBirthdays(birthdays) // Call the global save function
        
        isAddingBirthday = false // Close the modal
    }

    private func defaultNotificationTime() -> Date {
        var components = DateComponents()
        components.hour = 9 // Default to 9:00 AM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
