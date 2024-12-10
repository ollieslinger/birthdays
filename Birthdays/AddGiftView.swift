import SwiftUI

struct AddGiftView: View {
    @Binding var birthdays: [Birthday]
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedRecipient: UUID?
    @State private var giftName: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipient")) {
                    Picker("Select Recipient", selection: $selectedRecipient) {
                        ForEach(birthdays) { birthday in
                            Text(birthday.name)
                                .tag(birthday.id as UUID?)
                        }
                    }
                }

                Section(header: Text("Gift Name")) {
                    TextField("Enter gift name", text: $giftName)
                }

                Section {
                    Button("Add Gift") {
                        addGift()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(selectedRecipient == nil || giftName.isEmpty)
                }
            }
            .navigationTitle("Add Gift")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func addGift() {
        guard let recipientID = selectedRecipient else { return }
        if let index = birthdays.firstIndex(where: { $0.id == recipientID }) {
            let newGift = Birthday.Gift(id: UUID(), name: giftName, isPurchased: false)
            birthdays[index].giftIdeas.append(newGift)
        }
    }
}
