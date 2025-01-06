import SwiftUI

struct ManageGroupView: View {
    @Binding var groups: [TagGroup]
    @Binding var birthdays: [Birthday]
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedGroup: TagGroup?
    @State private var isEditingGroup = false // To track editing state

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("🎨 Manage Groups")
                .font(.custom("Bicyclette-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.top)

            Divider()
                .background(Color.gray)

            // Content Section
            if groups.isEmpty {
                // Empty State
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "person.3.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding()

                    Text("No groups created yet!")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(maxWidth: .infinity) // Allow full width
                .padding(.top, 40) // Add space from the top edge
            } else {
                List {
                    ForEach(groups) { group in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group.name)
                                    .font(.custom("Bicyclette-Bold", size: 18))
                                    .foregroundColor(.black)
                                Text("\(group.members.count) members")
                                    .font(.custom("Bicyclette-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                selectedGroup = group
                                isEditingGroup = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
//                        .padding()
                        .background(Color.white.opacity(0.9))
//                        .cornerRadius(10)
//                        .shadow(radius: 2)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.orange, lineWidth: 1)
//                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteGroup(group)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal)
            }

            Spacer()

            // Add Group Button
            Button(action: {
                let newGroup = TagGroup(name: "New Group")
                groups.append(newGroup)
                selectedGroup = newGroup
                isEditingGroup = true
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Create New Group")
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
        .sheet(item: $selectedGroup) { group in
            GroupEditorView(group: group, birthdays: $birthdays, onSave: { updatedGroup in
                if let index = groups.firstIndex(where: { $0.id == updatedGroup.id }) {
                    groups[index] = updatedGroup
                    saveGroups(groups) // Persist groups to storage
                    print("[DEBUG] Group '\(updatedGroup.name)' saved with members: \(updatedGroup.members)")
                }
            })
        }
    }

    // MARK: - Delete Group
    private func deleteGroup(_ group: TagGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups.remove(at: index)
            saveGroups(groups)
            print("[DEBUG] Group '\(group.name)' deleted.")
        }
    }
}
