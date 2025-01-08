//
//  BirthdayWidgetLiveActivity.swift
//  BirthdayWidget
//
//  Created by Ollie Hunter on 31/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BirthdayWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BirthdayWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BirthdayWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BirthdayWidgetAttributes {
    fileprivate static var preview: BirthdayWidgetAttributes {
        BirthdayWidgetAttributes(name: "World")
    }
}

extension BirthdayWidgetAttributes.ContentState {
    fileprivate static var smiley: BirthdayWidgetAttributes.ContentState {
        BirthdayWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BirthdayWidgetAttributes.ContentState {
         BirthdayWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BirthdayWidgetAttributes.preview) {
   BirthdayWidgetLiveActivity()
} contentStates: {
    BirthdayWidgetAttributes.ContentState.smiley
    BirthdayWidgetAttributes.ContentState.starEyes
}
