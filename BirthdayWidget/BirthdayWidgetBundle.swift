//
//  BirthdayWidgetBundle.swift
//  BirthdayWidget
//
//  Created by Ollie Hunter on 31/01/2025.
//

import WidgetKit
import SwiftUI
import Foundation

@main
struct BirthdayWidgetBundle: WidgetBundle {
    var body: some Widget {
        BirthdayWidget()
        BirthdayWidgetControl()
        BirthdayWidgetLiveActivity()
    }
}
