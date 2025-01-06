import SwiftUI

struct EditGiftView: View {
    @Binding var birthdays: [Birthday]
    var gift: Birthday.Gift
    var recipient: Birthday
    var onSave: (Birthday.Gift) -> Void // Callback to persist changes

    @State private var giftName: String
    @State private var giftLink: String
    @State private var showAlert = false

    @Environment(\.presentationMode) var presentationMode

    private let maxGiftNameLength = 30 // Character limit for gift name

    init(birthdays: Binding<[Birthday]>, gift: Birthday.Gift, recipient: Birthday, onSave: @escaping (Birthday.Gift) -> Void) {
        self._birthdays = birthdays
        self.gift = gift
        self.recipient = recipient
        self.onSave = onSave

        // Pre-populate the fields
        _giftName = State(initialValue: gift.name)
        _giftLink = State(initialValue: gift.link ?? "")
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("🎁 Edit Gift")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)

                Divider()
                    .background(Color.gray)

                // Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    // Recipient Display
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipient")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)
                        Text(recipient.name)
                            .font(.custom("Bicyclette-Regular", size: 16))
                            .foregroundColor(.gray)
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
                            .onChange(of: giftName) { oldValue, newValue in
                                if newValue.count > maxGiftNameLength {
                                    giftName = String(newValue.prefix(maxGiftNameLength))
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

                        // Character count indicator
                        Text("\(giftName.count)/\(maxGiftNameLength) characters")
                            .font(.custom("Bicyclette-Regular", size: 12))
                            .foregroundColor(giftName.count == maxGiftNameLength ? .red : .gray)
                    }

                    // Gift Link Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gift Link (Optional)")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)

                        TextField("Enter gift link (e.g., https://example.com)", text: $giftLink)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
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
                    if giftName.isEmpty {
                        showAlert = true
                    } else {
                        saveGift()
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Save Changes")
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
                Alert(
                    title: Text("Invalid Entry"),
                    message: Text("Gift name cannot be empty."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveGift() {
        var updatedGift = gift
        updatedGift.name = giftName
        updatedGift.link = giftLink.isEmpty ? nil : giftLink
        onSave(updatedGift)
    }
}
