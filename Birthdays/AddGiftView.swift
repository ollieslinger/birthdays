import SwiftUI

struct AddGiftView: View {
    @Binding var birthdays: [Birthday]
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedRecipient: UUID?
    @State private var giftName: String = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("🎁 Add Gift")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)

                Divider()
                    .background(Color.gray)

                // Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    // Recipient Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipient")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)

                        Picker("Select Recipient", selection: $selectedRecipient) {
                            ForEach(birthdays) { birthday in
                                Text(birthday.name).tag(birthday.id as UUID?)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                    }

                    // Gift Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gift Name")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)

                        TextField("Enter gift name", text: $giftName)
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
                    if giftName.isEmpty || selectedRecipient == nil {
                        showAlert = true
                    } else {
                        addGift()
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Save Gift")
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
                Alert(title: Text("Invalid Entry"), message: Text("Please fill in all fields."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addGift() {
        guard let recipientID = selectedRecipient else { return }
        if let index = birthdays.firstIndex(where: { $0.id == recipientID }) {
            let newGift = Birthday.Gift(id: UUID(), name: giftName, isPurchased: false)
            birthdays[index].giftIdeas.append(newGift)
            saveBirthdays(birthdays) // Call the global save function

        }
    }
}
