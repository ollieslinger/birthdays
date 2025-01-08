import SwiftUI

struct PresentListView: View {
    @Binding var birthdays: [Birthday] // To allow adding gifts
    @State private var isAddingGift = false // State to show the add gift sheet
    @State private var selectedGiftAndRecipient: GiftRecipientPair? // Optional to track the selected gift and recipient

    var giftsWithRecipients: [(gift: Birthday.Gift, recipient: Birthday)] {
        birthdays.flatMap { birthday in
            birthday.giftIdeas.map { (gift: $0, recipient: birthday) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("🎁 Gift Ideas")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                Spacer()
                Button(action: clearGifts) {
                    Text("Clear All")
                        .font(.custom("Bicyclette-Bold", size: 16))
                        .foregroundColor(giftsWithRecipients.isEmpty ? .gray : .red)
                }
                .disabled(giftsWithRecipients.isEmpty)
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()
                .background(Color.gray)

            // Content Section
            if giftsWithRecipients.isEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "gift.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding()

                    Text("No gifts added yet!")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(maxWidth: .infinity) // Allow full width
                .padding(.top, 40) // Add space from the top edge
            } else {
                List {
                    ForEach(giftsWithRecipients, id: \.gift.id) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.gift.name)
                                    .font(.custom("Bicyclette-Bold", size: 18))
                                Text("For: \(item.recipient.name)")
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .foregroundColor(.gray)
                                Text("Next Birthday: \(item.recipient.nextBirthdayFormatted)")
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if item.gift.isPurchased {
                                Text("Purchased")
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .foregroundColor(.green)
                            } else {
                                Text("Not Purchased")
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .foregroundColor(.red)
                            }
                        }
                        .background(Color.white.opacity(0.9))
                        .onTapGesture {
                            selectedGiftAndRecipient = GiftRecipientPair(gift: item.gift, recipient: item.recipient)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteGift(item.gift, from: item.recipient)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                markGiftAsPurchased(item.gift, for: item.recipient)
                            } label: {
                                Label(item.gift.isPurchased ? "Unmark" : "Mark as Purchased", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            Spacer()

            // Add Gift Button
            Button(action: { isAddingGift = true }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Add Gift")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.orange)
                    Spacer()
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
            .padding(.horizontal)
        }
        .background(Color.white)
        .sheet(isPresented: $isAddingGift) {
            AddGiftView(birthdays: $birthdays)
        }
        .sheet(item: $selectedGiftAndRecipient) { pair in
            EditGiftView(
                birthdays: $birthdays,
                gift: pair.gift,
                recipient: pair.recipient,
                onSave: { updatedGift in
                    updateGift(updatedGift, for: pair.recipient)
                }
            )
        }
    }

    // MARK: - Actions
    private func deleteGift(_ gift: Birthday.Gift, from recipient: Birthday) {
        if let recipientIndex = birthdays.firstIndex(where: { $0.id == recipient.id }) {
            birthdays[recipientIndex].giftIdeas.removeAll { $0.id == gift.id }
            saveBirthdays(birthdays)
        }
    }

    private func markGiftAsPurchased(_ gift: Birthday.Gift, for recipient: Birthday) {
        if let recipientIndex = birthdays.firstIndex(where: { $0.id == recipient.id }),
           let giftIndex = birthdays[recipientIndex].giftIdeas.firstIndex(where: { $0.id == gift.id }) {
            birthdays[recipientIndex].giftIdeas[giftIndex].isPurchased.toggle()
            saveBirthdays(birthdays)
        }
    }

    private func clearGifts() {
        for i in birthdays.indices {
            birthdays[i].giftIdeas.removeAll()
        }
        saveBirthdays(birthdays)
    }

    private func updateGift(_ updatedGift: Birthday.Gift, for recipient: Birthday) {
        if let recipientIndex = birthdays.firstIndex(where: { $0.id == recipient.id }),
           let giftIndex = birthdays[recipientIndex].giftIdeas.firstIndex(where: { $0.id == updatedGift.id }) {
            birthdays[recipientIndex].giftIdeas[giftIndex] = updatedGift
            saveBirthdays(birthdays)
        }
    }
}

// MARK: - GiftRecipientPair
struct GiftRecipientPair: Identifiable {
    let gift: Birthday.Gift
    let recipient: Birthday
    var id: String { gift.id.uuidString } // Conform to Identifiable using the gift's ID
}
