import SwiftUI

struct AddGroupView: View {
    @Binding var groups: [TagGroup]
    @State private var groupName: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create New Group")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .padding(.top)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group Name")
                        .font(.custom("Bicyclette-Bold", size: 18))
                    
                    TextField("Enter group name", text: $groupName)
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
                
                Spacer()
                
                Button(action: saveGroup) {
                    HStack {
                        Spacer()
                        Text("Create Group")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(groupName.isEmpty ? Color.gray : Color.orange)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(groupName.isEmpty)
            }
            .padding()
        }
    }

    private func saveGroup() {
        let newGroup = TagGroup(name: groupName)
        groups.append(newGroup)
        saveGroups(groups)
        presentationMode.wrappedValue.dismiss()
    }
}
