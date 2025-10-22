//
//  TodayCoursesWidgetLiveActivity.swift
//  TodayCoursesWidget
//
//  Created by 李嘉俊 on 2025/10/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TodayCoursesWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TodayCoursesWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TodayCoursesWidgetAttributes.self) { context in
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

extension TodayCoursesWidgetAttributes {
    fileprivate static var preview: TodayCoursesWidgetAttributes {
        TodayCoursesWidgetAttributes(name: "World")
    }
}

extension TodayCoursesWidgetAttributes.ContentState {
    fileprivate static var smiley: TodayCoursesWidgetAttributes.ContentState {
        TodayCoursesWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TodayCoursesWidgetAttributes.ContentState {
         TodayCoursesWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TodayCoursesWidgetAttributes.preview) {
   TodayCoursesWidgetLiveActivity()
} contentStates: {
    TodayCoursesWidgetAttributes.ContentState.smiley
    TodayCoursesWidgetAttributes.ContentState.starEyes
}
