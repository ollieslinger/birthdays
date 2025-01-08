import SwiftUI

struct EditBirthdayView: View {
    @Binding var birthdays: [Birthday]
    var birthdayToEdit: Birthday
    @Binding var editBirthday: Birthday? // Controls modal dismissal
    
    @State private var name: String
    @State private var birthDate: Date
    @State private var giftIdeas: [Birthday.Gift] = []
    @State private var newGiftIdea: String = ""
    @State private var isShowingGiftEditor = false
    @State private var selectedGift: Birthday.Gift? // Selected gift for editing
    @State private var showUnsavedGiftAlert = false // Alert for unsaved gift idea
    @State private var notificationsEnabled: Bool // Tracks the notification toggle state
    @State private var selectedInterest: String // Tracks the selected interest
    
    init(birthdays: Binding<[Birthday]>, birthdayToEdit: Birthday, editBirthday: Binding<Birthday?>) {
        _birthdays = birthdays
        self.birthdayToEdit = birthdayToEdit
        _editBirthday = editBirthday
        _name = State(initialValue: birthdayToEdit.name)
        _birthDate = State(initialValue: birthdayToEdit.birthDate)
        _giftIdeas = State(initialValue: birthdayToEdit.giftIdeas)
        _notificationsEnabled = State(initialValue: birthdayToEdit.notificationsEnabled)
        _selectedInterest = State(initialValue: birthdayToEdit.interest ?? "Creativity") // Default to "Creativity"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("🎉 Edit Birthday")
                        .font(.custom("Bicyclette-Bold", size: 24))
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: toggleNotifications) {
                        Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(notificationsEnabled ? .orange : .gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                    .background(Color.gray)
                
                // Name, Date, and Interests Section
                VStack(alignment: .leading, spacing: 16) {
                    nameField
                    birthDatePicker
                    InterestPicker(selectedInterest: $selectedInterest) // Reusable InterestPicker
                }
                .padding(.horizontal)
                
                Divider()
                    .background(Color.gray)
                
                // Gift Ideas Section
                VStack(alignment: .leading, spacing: 16) {
                    giftIdeasHeader
                    giftIdeasList
                    addGiftField
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: saveChanges) {
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
            .alert(isPresented: $showUnsavedGiftAlert) {
                Alert(
                    title: Text("Unsaved Gift Idea"),
                    message: Text("You have an unsaved gift idea. Would you like to save it before leaving?"),
                    primaryButton: .default(Text("Save"), action: addGiftIdea),
                    secondaryButton: .cancel(Text("Don't Save"))
                )
            }
            .sheet(isPresented: $isShowingGiftEditor) {
                if let gift = selectedGift {
                    EditGiftView(
                        birthdays: $birthdays,
                        gift: gift,
                        recipient: birthdayToEdit
                    ) { updatedGift in
                        updateGift(updatedGift)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    private var nameField: some View {
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
    }
    
    private var birthDatePicker: some View {
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
    
    private var giftIdeasHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Gift Ideas (\(giftIdeas.count))")
                .font(.custom("Bicyclette-Bold", size: 18))
                .foregroundColor(.black)
            Text("Swipe right to mark as purchased. Swipe left to delete.")
                .font(.custom("Bicyclette-Regular", size: 14))
                .foregroundColor(.gray)
        }
    }
    
    private var giftIdeasList: some View {
        List {
            ForEach(giftIdeas) { gift in
                HStack {
                    Text(gift.name)
                        .font(.custom("Bicyclette-Regular", size: 16))
                        .onTapGesture {
                            selectedGift = gift
                            isShowingGiftEditor = true
                        }
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
        .frame(maxHeight: 200)
    }
    
    private var addGiftField: some View {
        HStack {
            TextField("Add gift idea", text: $newGiftIdea, onCommit: addGiftIdea)
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
    
    // MARK: - Actions
    private func toggleNotifications() {
        notificationsEnabled.toggle()
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].notificationsEnabled = notificationsEnabled
        }
        saveBirthdays(birthdays)
    }
    
    private func addGiftIdea() {
        guard !newGiftIdea.isEmpty else { return }
        let newGift = Birthday.Gift(id: UUID(), name: newGiftIdea, isPurchased: false)
        giftIdeas.append(newGift)
        updateBirthday()
        newGiftIdea = ""
    }
    
    private func deleteGift(_ gift: Birthday.Gift) {
        giftIdeas.removeAll { $0.id == gift.id }
        updateBirthday()
    }
    
    private func markGiftAsPurchased(_ gift: Birthday.Gift) {
        if let index = giftIdeas.firstIndex(where: { $0.id == gift.id }) {
            giftIdeas[index].isPurchased.toggle()
        }
        updateBirthday()
    }
    
    private func updateGift(_ updatedGift: Birthday.Gift) {
        if let index = giftIdeas.firstIndex(where: { $0.id == updatedGift.id }) {
            giftIdeas[index] = updatedGift
        }
        updateBirthday()
    }
    
    private func updateBirthday() {
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].giftIdeas = giftIdeas
        }
        saveBirthdays(birthdays)
    }
    
    // MARK: - Save Changes
    private func saveChanges() {
        if !newGiftIdea.isEmpty {
            showUnsavedGiftAlert = true
            return
        }
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].name = name
            birthdays[index].birthDate = birthDate
            birthdays[index].giftIdeas = giftIdeas
            birthdays[index].notificationsEnabled = notificationsEnabled
            birthdays[index].interest = selectedInterest // Save selected interest
        }
        saveBirthdays(birthdays)
        editBirthday = nil
    }
}
