//
//  TomorrowCoursesWidgetControl.swift
//  TomorrowCoursesWidget
//
//  Created by 李嘉俊 on 2025/10/25.
//

import WidgetKit
import SwiftUI
import AppIntents

// 使用AppIntent.swift中定义的RefreshCoursesIntent

// 定义符合TimelineEntry协议的结构体
struct ControlEntry: TimelineEntry {
    let date: Date
}

// 根据平台提供不同实现
#if os(iOS)
// iOS版本
struct TomorrowCoursesWidgetControl: Widget {
    let kind: String = "com.example.iosClubApp.TomorrowCoursesWidgetControl"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: ControlProvider()
        ) { entry in
            TomorrowCoursesWidgetControlEntryView(entry: entry)
                .containerBackground(for: .widget) { Color.white }
        }
        .configurationDisplayName("课表刷新")
        .description("快速刷新今日和明日课表")
        .supportedFamilies([.accessoryCircular])
    }
}

struct ControlProvider: TimelineProvider {
    typealias Entry = ControlEntry
    
    func placeholder(in context: Context) -> ControlEntry {
        ControlEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ControlEntry) -> Void) {
        completion(ControlEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ControlEntry>) -> Void) {
        let entry = ControlEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct TomorrowCoursesWidgetControlEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: ControlProvider.Entry
    
    var body: some View {
        VStack {
            if #available(iOS 17.0, *) {
                Button(intent: RefreshCoursesIntent()) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("刷新")
                            .font(.caption2)
                    }
                    .foregroundColor(Color.blue)
                }
            } else {
                // 旧版本显示静态视图
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("刷新")
                        .font(.caption2)
                }
                .foregroundColor(Color.blue)
            }
        }
    }
}
#else
// macOS版本
struct TomorrowCoursesWidgetControl: Widget {
    let kind: String = "com.example.iosClubApp.TomorrowCoursesWidgetControl"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: macOSProvider()
        ) { entry in
            MacOSTomorrowCoursesWidgetControlEntryView(entry: entry)
                .containerBackground(for: .widget) { Color.white }
        }
        .configurationDisplayName("课表刷新")
        .description("快速刷新今日和明日课表")
        .supportedFamilies([.systemSmall])
    }
}

struct macOSProvider: TimelineProvider {
    typealias Entry = ControlEntry
    
    func placeholder(in context: Context) -> ControlEntry {
        ControlEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ControlEntry) -> Void) {
        completion(ControlEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ControlEntry>) -> Void) {
        let entry = ControlEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct MacOSTomorrowCoursesWidgetControlEntryView : View {
    var entry: macOSProvider.Entry
    
    var body: some View {
        VStack {
            Button(action: {
                // 在macOS上触发刷新
                Task {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }) {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("刷新")
                        .font(.caption2)
                }
                .foregroundColor(Color.blue)
            }
        }
    }
}
#endif

#if os(iOS)
#Preview(as: .accessoryCircular) {
    TomorrowCoursesWidgetControl()
} timeline: {
    ControlEntry(date: Date())
}
#else
#Preview(as: .systemSmall) {
    TomorrowCoursesWidgetControl()
} timeline: {
    ControlEntry(date: Date())
}
#endif
