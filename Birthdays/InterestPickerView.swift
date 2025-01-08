import SwiftUI

struct InterestPicker: View {
    @Binding var selectedInterest: String // The currently selected interest
    private let interests = ["Creativity", "Outdoors", "Technology", "Fitness & Wellness", "Food & Cooking", "Travel & Adventure", "Music & Entertainment"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Interests")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.black)

            Picker("Select Interest", selection: $selectedInterest) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest).tag(interest)
                }
            }
            .pickerStyle(MenuPickerStyle()) // Compact dropdown menu style
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
}
