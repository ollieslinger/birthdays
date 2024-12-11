import SwiftUI

struct EditBirthdayView: View {
    @Binding var birthdays: [Birthday]
    var birthdayToEdit: Birthday
    @Binding var editBirthday: Birthday? // Add this binding to control modal dismissal
    
    @State private var name: String
    @State private var birthDate: Date
    @State private var giftIdeas: [Birthday.Gift] = []
    @State private var newGiftIdea: String = ""
    
    init(birthdays: Binding<[Birthday]>, birthdayToEdit: Birthday, editBirthday: Binding<Birthday?>) {
        _birthdays = birthdays
        self.birthdayToEdit = birthdayToEdit
        _editBirthday = editBirthday
        _name = State(initialValue: birthdayToEdit.name)
        _birthDate = State(initialValue: birthdayToEdit.birthDate)
        _giftIdeas = State(initialValue: birthdayToEdit.giftIdeas)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("🎉 Edit Birthday")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)
                
                Divider()
                    .background(Color.gray)
                
                // Name and Date Section
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)
                        
                        TextField("Enter name", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)
                        
                        DatePicker("Select date", selection: $birthDate, displayedComponents: .date)
                            .labelsHidden()
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
                
                Divider()
                    .background(Color.gray)
                
                // Gift Ideas Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gift Ideas (\(giftIdeas.count))")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.black)
                    
                    Text("Swipe right to mark as purchased. Swipe left to delete.")
                        .font(.custom("Bicyclette-Regular", size: 14))
                        .foregroundColor(.gray)
                    
                    List {
                        ForEach(giftIdeas) { gift in
                            HStack {
                                Text(gift.name)
                                    .font(.custom("Bicyclette-Regular", size: 16))
                                Spacer()
                                if gift.isPurchased {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteGift(gift)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    markGiftAsPurchased(gift)
                                } label: {
                                    Label("Purchased", systemImage: "checkmark")
                                }
                                .tint(.green)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 200) // Limit the height of the gift ideas list
                    
                    HStack {
                        TextField("Add gift idea", text: $newGiftIdea, onCommit: addGiftIdea) // Commit on pressing Return
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                        Button(action: addGiftIdea) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: saveAndDismiss) {
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
        }
    }
    // MARK: - Views
    private var giftIdeasHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Gift Ideas (\(giftIdeas.count))")
                .font(.headline)
                .foregroundColor(.primary) // Use primary color for better adaptability to themes
            Text("Swipe right to mark as purchased. Swipe left to delete.")
                .font(.footnote)
                .foregroundColor(.secondary) // Secondary color for a subtler look
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 4) // Add a bit of space after the header
    }
    
    // MARK: - Actions
    private func addGiftIdea() {
        guard !newGiftIdea.isEmpty else { return }
        let newGift = Birthday.Gift(id: UUID(), name: newGiftIdea, isPurchased: false)
        giftIdeas.append(newGift)
        
        // Update the birthday in the main list
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].giftIdeas = giftIdeas
        }
        
        newGiftIdea = ""
        saveBirthdays(birthdays) // Call the global save function
        
    }
    
    private func deleteGift(_ gift: Birthday.Gift) {
        // Remove the gift locally
        giftIdeas.removeAll { $0.id == gift.id }
        
        // Update the global birthdays list
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].giftIdeas = giftIdeas
        }
        saveBirthdays(birthdays) // Call the global save function
        
    }
    
    private func markGiftAsPurchased(_ gift: Birthday.Gift) {
        // Toggle the purchased state locally
        if let index = giftIdeas.firstIndex(where: { $0.id == gift.id }) {
            giftIdeas[index].isPurchased.toggle()
        }
        
        // Update the global birthdays list
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].giftIdeas = giftIdeas
        }
        saveBirthdays(birthdays) // Call the global save function
        
    }
    private func saveAndDismiss() {
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].name = name
            birthdays[index].birthDate = birthDate
            birthdays[index].giftIdeas = giftIdeas
        }
        saveBirthdays(birthdays) // Use the global save function
        editBirthday = nil // Dismiss the view
    }
}
