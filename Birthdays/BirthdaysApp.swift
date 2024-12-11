//
//  BirthdaysApp.swift
//  Birthdays
//
//  Created by Ollie Hunter on 08/12/2024.
//

import SwiftUI

@main
struct BirthdaysApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Request notification permissions during app initialization
        NotificationHelper.requestPermissions()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.appDelegate, appDelegate) // Pass the AppDelegate as an environment value
                .preferredColorScheme(.light) // Enforces light mode across the app
                .accentColor(.blue) // Set global accent color
        }
    }
}
