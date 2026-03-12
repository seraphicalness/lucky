//
//  HarugiwunWidgetLiveActivity.swift
//  HarugiwunWidget
//
//  Created by 김나희 on 3/12/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HarugiwunWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HarugiwunWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HarugiwunWidgetAttributes.self) { context in
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

extension HarugiwunWidgetAttributes {
    fileprivate static var preview: HarugiwunWidgetAttributes {
        HarugiwunWidgetAttributes(name: "World")
    }
}

extension HarugiwunWidgetAttributes.ContentState {
    fileprivate static var smiley: HarugiwunWidgetAttributes.ContentState {
        HarugiwunWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HarugiwunWidgetAttributes.ContentState {
         HarugiwunWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HarugiwunWidgetAttributes.preview) {
   HarugiwunWidgetLiveActivity()
} contentStates: {
    HarugiwunWidgetAttributes.ContentState.smiley
    HarugiwunWidgetAttributes.ContentState.starEyes
}
