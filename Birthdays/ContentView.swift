// Main ContentView
import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var birthdays: [Birthday] = []
    @State private var isAddingBirthday = false
    @State private var isShowingSettings = false
    @State private var searchText: String = ""
    @State private var filterOption: FilterOption = .upcoming
    @State private var editBirthday: Birthday? = nil

    enum FilterOption: String, CaseIterable {
        case upcoming = "Upcoming"
        case past = "Past"
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                headerWithToolbar
                searchBarView
                filterPickerView
                contentView
            }
            .onAppear {
                NotificationHelper.requestPermissions()
                loadBirthdays()
            }
            .background(Color.white)
            .sheet(isPresented: $isAddingBirthday) {
                AddBirthdayView(isAddingBirthday: $isAddingBirthday, birthdays: $birthdays)
            }
            .sheet(item: $editBirthday) { birthdayToEdit in
                EditBirthdayView(
                    birthdays: $birthdays,
                    birthdayToEdit: birthdayToEdit,
                    editBirthday: $editBirthday // Bind to editBirthday for dismissal
                )
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(birthdays: $birthdays)
            }
        }
    }

    // MARK: - Header with Toolbar
    private var headerWithToolbar: some View {
        HStack {
            Text("🎉 Birthdays")
                .font(.custom("Bicyclette-Bold", size: 36))
                .foregroundColor(.black)
            Spacer()
            notificationsButton
            presentListButton
            settingsButton
        }
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Search Bar
    private var searchBarView: some View {
        TextField("Search by name...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .font(.custom("Bicyclette-Regular", size: 14))
    }

    // MARK: - Filter Picker
    private var filterPickerView: some View {
        Picker("Filter", selection: $filterOption) {
            ForEach(FilterOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .font(.custom("Bicyclette-Regular", size: 14))
        .foregroundColor(.black)
    }

    // MARK: - Content View
    private var contentView: some View {
        Group {
            if birthdays.isEmpty {
                emptyStateView
            } else {
                VStack {
                    birthdayListView
                    addBirthdayButton
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "calendar.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding()

            Text("No birthdays yet!")
                .font(.custom("Bicyclette-Bold", size: 20))
                .foregroundColor(.gray)

            Button(action: {
                isAddingBirthday = true
            }) {
                Text("Add a Birthday")
                    .font(.custom("Bicyclette-Bold", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.top, 40)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Birthday List
    private var birthdayListView: some View {
        List {
            ForEach(filteredAndSearchedBirthdays) { birthday in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: filterOption == .upcoming ? "calendar.circle.fill" : "clock.fill")
                                .foregroundColor(filterOption == .upcoming ? .blue : .orange)
                                .padding(.trailing, 8)
                            Text(birthday.name)
                                .font(.custom("Bicyclette-Bold", size: 18))
                                .foregroundColor(.black)
                        }
                        Text(filterOption == .upcoming ?
                             "Turns \(birthday.ageAtNextBirthday) on \(birthday.nextBirthdayFormatted)" :
                             "Turned \(birthday.ageAtLastBirthday) on \(birthday.lastBirthdayFormatted)"
                        )
                        .font(.custom("Bicyclette-Regular", size: 14))
                        .foregroundColor(.gray)

                        if !birthday.giftIdeas.isEmpty {
                            Text("\(birthday.giftIdeas.count) gift ideas")
                                .font(.custom("Bicyclette-Regular", size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                    Spacer()
                    if filterOption == .upcoming {
                        Text("\(birthday.daysUntilNextBirthday) days")
                            .font(.custom("Bicyclette-Regular", size: 14))
                            .foregroundColor(.orange)
                    }
                    Button(action: {
                        editBirthday = birthday
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9)) // Keep the background neutral
                .cornerRadius(10)
                .shadow(color: cardShadowColor(for: birthday), radius: 5, x: 0, y: 2) // Dynamic shadow color
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(cardBorderColor(for: birthday), lineWidth: 1) // Add thin border
                )

            }
            .onDelete(perform: deleteBirthday)
        }
        .listStyle(PlainListStyle())
    }
    // MARK: - Add Birthday Button
    private var addBirthdayButton: some View {
        Button(action: {
            isAddingBirthday = true
        }) {
            Text("Add Another Birthday")
                .font(.custom("Bicyclette-Bold", size: 18))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
        }
        .padding(.top, 10)
    }

    // MARK: - Settings Button
    private var settingsButton: some View {
        Button(action: {
            isShowingSettings = true
        }) {
            Image(systemName: "gear")
                .foregroundColor(.orange)
                .font(.title2)
        }
    }

    // MARK: - Present List
    @State private var isShowingPresentList = false // State for the present list

    private var presentListButton: some View {
        Button(action: {
            isShowingPresentList = true
        }) {
            Image(systemName: "gift.fill")
                .foregroundColor(.orange)
                .font(.title2)
        }
        .sheet(isPresented: $isShowingPresentList) {
            PresentListView(birthdays: $birthdays)
        }
    }
    // MARK: - Methods
    @State private var isShowingNotificationsList = false // State for the notifications list

    private var notificationsButton: some View {
        Button(action: {
            isShowingNotificationsList = true
        }) {
            Image(systemName: "bell")
                .foregroundColor(.orange)
                .font(.title2)
        }
        .sheet(isPresented: $isShowingNotificationsList) {
            NotificationsListView()
        }
    }
    
    private var aggregatedGifts: [Birthday.Gift] {
        birthdays.flatMap { $0.giftIdeas }
    }
    

    private func loadBirthdays() {
        if let savedData = UserDefaults.standard.data(forKey: "birthdays"),
           let decoded = try? JSONDecoder().decode([Birthday].self, from: savedData) {
            birthdays = decoded
        }
    }

    private func deleteBirthday(at offsets: IndexSet) {
        withAnimation {
            // Map offsets from filteredAndSearchedBirthdays to the original birthdays array
            let originalIndices = offsets.map { index in
                let birthdayToDelete = filteredAndSearchedBirthdays[index]
                return birthdays.firstIndex { $0.id == birthdayToDelete.id }!
            }
            
            // Remove notifications and items from the original birthdays array
            originalIndices.forEach { index in
                let birthday = birthdays[index]
                // Remove notifications associated with the birthday
                removeNotifications(for: birthday)
                // Remove the birthday from the array
                birthdays.remove(at: index)
            }
            
            // Save the updated birthdays list
            saveBirthdays(birthdays) // Call the global save function
        }
    }

    private func removeNotifications(for birthday: Birthday) {
        let notificationIdentifiers = [
            "\(birthday.id.uuidString)-7",  // Notification 7 days before
            "\(birthday.id.uuidString)-1",  // Notification 1 day before
            "\(birthday.id.uuidString)-0"   // Notification on the day
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIdentifiers)
    }
    // MARK: - Helper Properties
    var filteredAndSearchedBirthdays: [Birthday] {
        let filteredBirthdays: [Birthday]
        switch filterOption {
        case .upcoming:
            filteredBirthdays = birthdays.filter { $0.nextBirthday >= Date() }
                .sorted(by: { $0.nextBirthday < $1.nextBirthday })
        case .past:
            filteredBirthdays = birthdays.filter { $0.lastBirthday < Date() }
                .sorted(by: { $0.lastBirthday > $1.lastBirthday })
        }
        return searchText.isEmpty ? filteredBirthdays :
            filteredBirthdays.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
}
    //MARK: Background Shadow Colour
    private func cardShadowColor(for birthday: Birthday) -> Color {
        if birthday.daysUntilNextBirthday > 7 {
            return Color.gray.opacity(0.5) // Default shadow for birthdays far away
        } else if birthday.daysUntilNextBirthday <= 7 && !birthday.isAnyGiftsPurchased {
            return Color.yellow.opacity(0.7) // Yellow for urgent birthdays
        } else if birthday.daysUntilNextBirthday <= 7 && birthday.isAnyGiftsPurchased {
            return Color.green.opacity(0.7) // Green for completed gifts
        }
        return Color.gray.opacity(0.5)
    }
    
    private func cardBorderColor(for birthday: Birthday) -> Color {
        if birthday.daysUntilNextBirthday > 7 {
            return Color.gray.opacity(0.5) // Default border
        } else if birthday.daysUntilNextBirthday <= 7 && !birthday.isAnyGiftsPurchased {
            return Color.yellow.opacity(0.7) // Yellow for urgent birthdays
        } else if birthday.daysUntilNextBirthday <= 7 && birthday.isAnyGiftsPurchased {
            return Color.green.opacity(0.7) // Green for completed gifts
        }
        return Color.gray.opacity(0.5)
    }
