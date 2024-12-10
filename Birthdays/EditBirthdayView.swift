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
            Form {
                Section(header: Text("Birthday Details")) {
                    TextField("Name", text: $name)
                    DatePicker("Date of Birth", selection: $birthDate, displayedComponents: .date)
                }

                Section(header: giftIdeasHeader) {
                    List {
                        ForEach(giftIdeas) { gift in
                            HStack {
                                Text(gift.name)
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
                                    Label("Mark as Purchased", systemImage: "checkmark")
                                }
                                .tint(.green)
                            }
                        }
                    }

                    HStack {
                        TextField("Add gift idea", text: $newGiftIdea)
                        Button(action: addGiftIdea) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Edit Birthday")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editBirthday = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                }
            }
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
        giftIdeas.append(Birthday.Gift(id: UUID(), name: newGiftIdea, isPurchased: false))
        newGiftIdea = ""
    }

    private func deleteGift(_ gift: Birthday.Gift) {
        giftIdeas.removeAll { $0.id == gift.id }
    }

    private func markGiftAsPurchased(_ gift: Birthday.Gift) {
        if let index = giftIdeas.firstIndex(where: { $0.id == gift.id }) {
            giftIdeas[index].isPurchased.toggle()
        }
    }

    private func saveAndDismiss() {
        if let index = birthdays.firstIndex(where: { $0.id == birthdayToEdit.id }) {
            birthdays[index].name = name
            birthdays[index].birthDate = birthDate
            birthdays[index].giftIdeas = giftIdeas
        }
        editBirthday = nil
    }
}
