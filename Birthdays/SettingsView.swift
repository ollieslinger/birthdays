import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Binding var birthdays: [Birthday]
    @State private var groups: [TagGroup] = loadGroups() // Load saved groups
    @State private var isShowingGroupEditor = false // Controls AddGroupView
    @State private var isShowingEditGroup = false // Controls EditGroupView
    @State private var showDocumentPicker = false
    @State private var isShowingTimePicker = false // Toggles picker visibility
    // Use @AppStorage so the value is automatically stored/retrieved.
    @AppStorage("notificationTime") private var notificationTime: Date = defaultNotificationTime
    @State private var parsedBirthdays: [Birthday] = []
    @State private var showConfirmationPage = false
    @Environment(\.appDelegate) var appDelegate

    static var defaultNotificationTime: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                // Use a ScrollView to handle overflow and allow for safe area adjustments.
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        Text("⚙️ Settings")
                            .font(.custom("Bicyclette-Bold", size: 24))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            // Add extra top padding based on the safe area inset.
                            .padding(.top, geometry.safeAreaInsets.top + 10)
                        
                        Divider()
                            .background(Color.gray)
                        
                        // Notifications Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notifications")
                                .font(.custom("Bicyclette-Bold", size: 20))
                                .foregroundColor(.black)
                                .padding(.bottom, 8)
                            notificationTimeSection
                        }
                        .padding(.horizontal)
                        
                        // Import/Export Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Import/Export")
                                .font(.custom("Bicyclette-Bold", size: 20))
                                .foregroundColor(.black)
                                .padding(.bottom, 8)
                            exportButton
                            importButton
                        }
                        .padding(.horizontal)
                        
                        // Groups Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Groups")
                                .font(.custom("Bicyclette-Bold", size: 20))
                                .foregroundColor(.black)
                                .padding(.bottom, 8)
                            groupsSection
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                }
                // Ensure that the ScrollView ignores the top safe area so we can add our own padding.
                .edgesIgnoringSafeArea(.top)
            }
            // Sheet modifiers remain unchanged.
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(birthdays: $birthdays, parsedBirthdays: $parsedBirthdays, showConfirmationPage: $showConfirmationPage)
            }
            .sheet(isPresented: $showConfirmationPage) {
                ImportConfirmationView(
                    parsedBirthdays: $parsedBirthdays,
                    onConfirm: { selectedBirthdays in
                        birthdays.append(contentsOf: selectedBirthdays)
                        saveBirthdays(birthdays) // Call the global save function
                    },
                    onCancel: {
                        showConfirmationPage = false
                    }
                )
            }
            .sheet(isPresented: $isShowingGroupEditor) {
                AddGroupView(groups: $groups)
            }
            .sheet(isPresented: $isShowingEditGroup) {
                ManageGroupView(groups: $groups, birthdays: $birthdays)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Groups Section
    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Button to create a new group
            Button(action: { isShowingGroupEditor = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create New Group")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)
                        Text("Add a new group to organize birthdays.")
                            .font(.custom("Bicyclette-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
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
            
            // Button to manage existing groups
            Button(action: { isShowingEditGroup = true }) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manage Groups")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)
                        Text("Edit or delete existing groups.")
                            .font(.custom("Bicyclette-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
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
        }
    }
    
    // MARK: - Notification Time Section
    private var notificationTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { withAnimation { isShowingTimePicker.toggle() } }) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notification Time")
                            .font(.custom("Bicyclette-Bold", size: 18))
                            .foregroundColor(.black)
                        Text("Set the time when notifications are sent.")
                            .font(.custom("Bicyclette-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: isShowingTimePicker ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
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
            
            if isShowingTimePicker {
                VStack(spacing: 16) {
                    DatePicker(
                        "",
                        selection: $notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding(.horizontal)
                    
                    Button("Confirm Time") {
                        confirmNotificationTime()
                        withAnimation {
                            isShowingTimePicker = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .zIndex(1)
    }
    
    // MARK: - Export Button
    private var exportButton: some View {
        Button(action: exportToCSV) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Birthdays")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.black)
                    Text("Download your birthdays as a CSV file.")
                        .font(.custom("Bicyclette-Regular", size: 14))
                        .foregroundColor(.gray)
                }
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
    }
    
    // MARK: - Import Button
    private var importButton: some View {
        Button(action: { showDocumentPicker = true }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Import Birthdays")
                        .font(.custom("Bicyclette-Bold", size: 18))
                        .foregroundColor(.black)
                    Text("Load birthdays from a CSV file.")
                        .font(.custom("Bicyclette-Regular", size: 14))
                        .foregroundColor(.gray)
                }
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
    }
    
    private func saveNotificationTime() {
        print("📌 [DEBUG] notificationTime before saving: \(notificationTime)")
        UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        print("✅ [DEBUG] Saved notification time: \(formattedTime(notificationTime))")
    }

    private func confirmNotificationTime() {
        saveNotificationTime()
        print("Notification time saved: \(formattedTime(notificationTime))")
        appDelegate?.scheduleAppRefresh()
        print("App refresh rescheduled with the new notification time.")
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func exportToCSV() {
        let csvString = birthdaysToCSV()
        let fileName = "Birthdays.csv"
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent(fileName)
        
        do {
            try FileManager.default.createDirectory(at: tempURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        rootVC.present(activityVC, animated: true)
                    }
                }
            }
        } catch {
            print("Failed to write CSV file: \(error.localizedDescription)")
        }
    }
    
    private func birthdaysToCSV() -> String {
        var csv = "Name,BirthDate,GiftIdeas\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for birthday in birthdays {
            let giftIdeas = birthday.giftIdeas.map { $0.name }.joined(separator: ";")
            let date = dateFormatter.string(from: birthday.birthDate)
            csv += "\(birthday.name),\(date),\(giftIdeas)\n"
        }
        return csv
    }
}
