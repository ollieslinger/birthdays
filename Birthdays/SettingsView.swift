import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Binding var birthdays: [Birthday]
    @State private var showDocumentPicker = false
    @State private var parsedBirthdays: [Birthday] = []
    @State private var showConfirmationPage = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("⚙️ Settings")
                    .font(.custom("Bicyclette-Bold", size: 36))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                
                Button(action: exportToCSV) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        Text("Export Birthdays")
                            .font(.custom("Bicyclette-Bold", size: 18))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button(action: { showDocumentPicker = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                        Text("Import Birthdays")
                            .font(.custom("Bicyclette-Bold", size: 18))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker(birthdays: $birthdays, parsedBirthdays: $parsedBirthdays, showConfirmationPage: $showConfirmationPage)
                }
                .sheet(isPresented: $showConfirmationPage) {
                    ImportConfirmationView(
                        parsedBirthdays: $parsedBirthdays,
                        onConfirm: { selectedBirthdays in
                            birthdays.append(contentsOf: selectedBirthdays)
                            saveBirthdays()
                        },
                        onCancel: {
                            showConfirmationPage = false
                        }
                    )
                }
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    private func exportToCSV() {
        let csvString = birthdaysToCSV()
        let fileName = "Birthdays.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
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
    private func saveBirthdays() {
        if let encoded = try? JSONEncoder().encode(birthdays) {
            UserDefaults.standard.set(encoded, forKey: "birthdays")
        }
    }
}
