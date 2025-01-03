import SwiftUI
import Foundation

struct ImportConfirmationView: View {
    @Binding var parsedBirthdays: [Birthday]
    @State private var selectedBirthdays: Set<UUID> = []
    @State private var selectAll = false // Tracks the state of the "Select All" button
    @Environment(\.presentationMode) var presentationMode // For dismissing the view

    var onConfirm: ([Birthday]) -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("Select Birthdays to Import")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .padding()

                // "Select All" Button
                Button(action: toggleSelectAll) {
                    Text(selectAll ? "Deselect All" : "Select All")
                        .font(.custom("Bicyclette-Bold", size: 16))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom)

                // List or Empty State
                if parsedBirthdays.isEmpty {
                    Text("No birthdays to import.")
                        .font(.custom("Bicyclette-Regular", size: 18))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(parsedBirthdays, id: \.id) { birthday in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(birthday.name)
                                    .font(.headline)
                                Text("Date of Birth: \(DateFormatter.localizedString(from: birthday.birthDate, dateStyle: .medium, timeStyle: .none))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle(isOn: Binding(
                                get: { selectedBirthdays.contains(birthday.id) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedBirthdays.insert(birthday.id)
                                    } else {
                                        selectedBirthdays.remove(birthday.id)
                                    }
                                }
                            )) {
                                EmptyView()
                            }
                            .labelsHidden()
                        }
                    }
                }

                // Buttons for "Cancel" and "Confirm"
                HStack {
                    Button(action: {
                        onCancel()
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Text("Cancel")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        confirmSelection()
                    }) {
                        Text("Confirm")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .onAppear {
                print("Parsed Birthdays: \(parsedBirthdays)") // Debugging
            }
        }
    }

    private func toggleSelectAll() {
        selectAll.toggle()

        if selectAll {
            // Select all birthdays
            selectedBirthdays = Set(parsedBirthdays.map { $0.id })
        } else {
            // Deselect all birthdays
            selectedBirthdays.removeAll()
        }
    }

    private func confirmSelection() {
        // Filter the selected birthdays
        let selected = parsedBirthdays.filter { selectedBirthdays.contains($0.id) }
        
        // Pass selected birthdays back and dismiss
        onConfirm(selected)
        presentationMode.wrappedValue.dismiss() // Dismiss the view
    }
}
