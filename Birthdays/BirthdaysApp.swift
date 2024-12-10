//
//  BirthdaysApp.swift
//  Birthdays
//
//  Created by Ollie Hunter on 08/12/2024.
//

import SwiftUI

@main
struct BirthdaysApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light) // Enforces light mode across the app
                .accentColor(.blue) // Set global accent color
        }
    }
}
