import SwiftUI

struct GroupEditorView: View {
    @State var group: TagGroup
    @Binding var birthdays: [Birthday]
    var onSave: (TagGroup) -> Void // Callback for saving changes
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedBirthdays: Set<UUID> = []
    @State private var selectAll = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
              // Add padding at the top
              Spacer().frame(height: 16) // Adds extra space at the top
                TextField("Group Name", text: $group.name)
                .font(.custom("Bicyclette-Bold", size: 20))
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange, lineWidth: 1)
                )
                .padding(.horizontal)

            Divider()
                .background(Color.gray)

            HStack {
                Text("Select Members")
                    .font(.custom("Bicyclette-Bold", size: 18))
                    .foregroundColor(.black)
                Spacer()
                Button(action: toggleSelectAll) {
                    Text(selectAll ? "Deselect All" : "Select All")
                        .font(.custom("Bicyclette-Regular", size: 16))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            List {
                ForEach(birthdays) { birthday in
                    HStack {
                        Text(birthday.name)
                            .font(.custom("Bicyclette-Regular", size: 16))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { selectedBirthdays.contains(birthday.id) },
                            set: { isSelected in
                                updateSelection(birthday: birthday, isSelected: isSelected)
                            }
                        ))
                        .labelsHidden()
                    }
                }
            }
            .listStyle(PlainListStyle())

            Spacer()

            // Save Button
            Button(action: saveGroup) {
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
        .onAppear {
            selectedBirthdays = Set(group.members)
        }
        .background(Color.white)
    }

    // MARK: - Actions
    private func toggleSelectAll() {
        selectAll.toggle()
        if selectAll {
            selectedBirthdays = Set(birthdays.map(\.id))
        } else {
            selectedBirthdays.removeAll()
        }
    }

    private func updateSelection(birthday: Birthday, isSelected: Bool) {
        if isSelected {
            selectedBirthdays.insert(birthday.id)
            print("[DEBUG] Added \(birthday.name) to group '\(group.name)'")
        } else {
            selectedBirthdays.remove(birthday.id)
            print("[DEBUG] Removed \(birthday.name) from group '\(group.name)'")
        }
    }

    private func saveGroup() {
        group.members = Array(selectedBirthdays) // Update group members
        onSave(group) // Persist changes
        presentationMode.wrappedValue.dismiss()
    }
}
