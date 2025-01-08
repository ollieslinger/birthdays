import SwiftUI

struct AddGiftView: View {
    @Binding var birthdays: [Birthday]
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedRecipient: UUID?
    @State private var giftName: String = ""
    @State private var giftLink: String = ""
    @State private var showAlert = false
    private let maxGiftNameLength = 50 // Character limit for gift name

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                Divider().background(Color.gray)
                inputFields
                Spacer()
                saveButton
            }
            .background(Color.white)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Entry"),
                    message: Text("Please fill in all fields."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        Text("🎁 Add Gift")
            .font(.custom("Bicyclette-Bold", size: 24))
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.top)
    }

    // MARK: - Input Fields
    private var inputFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            recipientPicker
            giftNameField
            giftLinkField
        }
        .padding(.horizontal)
    }

    private var recipientPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recipient")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.black)

            Picker("Select Recipient", selection: $selectedRecipient) {
                Text("Pick Someone").tag(UUID?.none)
                ForEach(birthdays.sorted(by: { $0.name < $1.name })) { birthday in
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
    }

    private var giftNameField: some View {
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

            Text("\(giftName.count)/\(maxGiftNameLength) characters")
                .font(.custom("Bicyclette-Regular", size: 12))
                .foregroundColor(giftName.count == maxGiftNameLength ? .red : .gray)
        }
    }

    private var giftLinkField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gift Link (Optional)")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.black)

            TextField("Enter web link", text: $giftLink)
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

    // MARK: - Save Button
    private var saveButton: some View {
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

    // MARK: - Add Gift Logic
    private func addGift() {
        guard let recipientID = selectedRecipient else { return }
        if let index = birthdays.firstIndex(where: { $0.id == recipientID }) {
            let newGift = Birthday.Gift(id: UUID(), name: giftName, link: giftLink.isEmpty ? nil : giftLink, isPurchased: false)
            birthdays[index].giftIdeas.append(newGift)
            saveBirthdays(birthdays) // Save updates
        }
    }
}
