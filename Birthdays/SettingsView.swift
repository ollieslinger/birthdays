import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Binding var birthdays: [Birthday]
    @State private var showDocumentPicker = false
    @State private var isShowingTimePicker = false // Toggles picker visibility
    @AppStorage("notificationTime") private var notificationTime: Date = defaultNotificationTime
    @State private var parsedBirthdays: [Birthday] = []
    @State private var showConfirmationPage = false
    @Environment(\.appDelegate) var appDelegate

    static var defaultNotificationTime: Date {
        var components = DateComponents()
        components.hour = 9 // Default to 9:00 AM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("⚙️ Settings")
                    .font(.custom("Bicyclette-Bold", size: 24))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)
                Divider()
                    .background(Color.gray)

                // Buttons Section
                VStack(alignment: .leading, spacing: 16) {
                    // Notification Time Concertina
                    notificationTimeSection

                    // Export Button
                    exportButton

                    // Import Button
                    importButton
                }
                .padding(.horizontal)

                Spacer()
            }
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
            .background(Color.white)
            .navigationBarHidden(true)
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

            // Ensure DatePicker is below the button without overlap
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
                            isShowingTimePicker = false // Collapse the section
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top, 8) // Add spacing between the button and the picker
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .zIndex(1) // Ensure proper stacking to avoid layout conflicts
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
        UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
    }

    private func confirmNotificationTime() {
        saveNotificationTime() // Persist the updated notification time
        print("Notification time saved: \(formattedTime(notificationTime))")

        appDelegate?.scheduleAppRefresh() // Use Environment appDelegate
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
            // Ensure the directory exists
            try FileManager.default.createDirectory(at: tempURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            // Write the CSV file
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            // Dismiss any active sheets
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.dismiss(animated: true) { // Ensure dismissal happens
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
        dateFormatter.dateFormat = "dd/MM/yyyy" // Consistent date format

        for birthday in birthdays {
            // Map giftIdeas to their names and join them with a semicolon
            let giftIdeas = birthday.giftIdeas.map { $0.name }.joined(separator: ";")
            let date = dateFormatter.string(from: birthday.birthDate)
            csv += "\(birthday.name),\(date),\(giftIdeas)\n"
        }
        return csv
    }
}
