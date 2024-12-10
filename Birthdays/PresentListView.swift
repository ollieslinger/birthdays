import SwiftUI

struct PresentListView: View {
    @Binding var birthdays: [Birthday] // To allow adding gifts
    @State private var isAddingGift = false // State to show the add gift sheet

    var giftsWithRecipients: [(gift: Birthday.Gift, recipient: Birthday)] {
        birthdays.flatMap { birthday in
            birthday.giftIdeas.map { (gift: $0, recipient: birthday) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if giftsWithRecipients.isEmpty {
                    Text("No gifts added yet!")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(giftsWithRecipients, id: \.gift.id) { item in
                            HStack {
                                VStack(alignment: .leading) {
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
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                // Add Gift Button
                Button(action: { isAddingGift = true }) {
                    Text("Add Gift")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("🎁 Gift Ideas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss the view
                    }
                }
            }
            .sheet(isPresented: $isAddingGift) {
                AddGiftView(birthdays: $birthdays)
            }
        }
    }
}
