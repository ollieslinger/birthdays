import SwiftUI
import Foundation

struct ImportConfirmationView: View {
    @Binding var parsedBirthdays: [Birthday]
    @State private var selectedBirthdays: Set<UUID> = []

    var onConfirm: ([Birthday]) -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Birthdays to Import")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .padding()

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

                HStack {
                    Button(action: {
                        print("Cancel pressed.") // Debugging
                        onCancel()
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
                        print("Confirm pressed.") // Debugging
                        let selected = parsedBirthdays.filter { selectedBirthdays.contains($0.id) }
                        print("Selected Birthdays: \(selected)") // Debugging
                        onConfirm(selected)
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
}
