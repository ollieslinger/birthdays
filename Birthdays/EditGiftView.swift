import SwiftUI

struct EditGiftView: View {
    @Binding var birthdays: [Birthday]
    var gift: Birthday.Gift
    var recipient: Birthday
    var onSave: (Birthday.Gift) -> Void // Callback to persist changes

    @State private var giftName: String = ""
    @State private var giftLink: String = ""
    @State private var showAlert = false
    @State private var showShareSheet = false // For presenting the share sheet
    @State private var shareText = "" // Text to be shared

    @Environment(\.presentationMode) var presentationMode

    private let maxGiftNameLength = 30 // Character limit for gift name

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
                    recipientDisplay
                    giftNameInput
                    giftLinkInput
                }
                .padding(.horizontal)

                Spacer()

                // Save and Share Buttons
                HStack(spacing: 16) {
                    saveButton
                    shareButton
                }
                .padding(.horizontal)
            }
            .background(Color.white)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Entry"),
                    message: Text("Gift name cannot be empty."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                initializeFields()
            }
        }
    }

    // MARK: - Recipient Display
    private var recipientDisplay: some View {
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
    }

    // MARK: - Gift Name Input
    private var giftNameInput: some View {
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

    // MARK: - Gift Link Input
    private var giftLinkInput: some View {
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

    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: {
            if giftName.isEmpty {
                showAlert = true
            } else {
                saveGift()
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Text("Save Changes")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
        }
    }

    // MARK: - Share Button
    private var shareButton: some View {
        Button(action: {
            generateShareText()
            showShareSheet = true
        }) {
            Text("Share")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText])
        }
    }

    // MARK: - Save Gift
    private func saveGift() {
        var updatedGift = gift
        updatedGift.name = giftName
        updatedGift.link = giftLink.isEmpty ? nil : giftLink
        onSave(updatedGift)
    }

    // MARK: - Generate Share Text
    private func generateShareText() {
        let age = recipient.ageAtNextBirthday
        let birthdayDate = recipient.nextBirthdayFormatted
        shareText = """
        I'm buying a gift for \(recipient.name), they are turning \(age) on \(birthdayDate).
        I'm thinking of getting \(giftName).\(giftLink.isEmpty ? "" : " Here's the link: \(giftLink)")
        What do you think?
        """
    }

    // MARK: - Initialize Fields
    private func initializeFields() {
        giftName = gift.name
        giftLink = gift.link ?? ""
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
