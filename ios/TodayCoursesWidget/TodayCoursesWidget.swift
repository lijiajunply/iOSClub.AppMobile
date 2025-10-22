//
//  TodayCoursesWidget.swift
//  TodayCoursesWidget
//
//  Created by iOS Club App team.
//

import SwiftUI
import WidgetKit
import Foundation

private let widgetGroupId = "group.com.example.iosClubApp.widget"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CourseEntry {
        CourseEntry(
            date: Date(),
            title: "今日课表",
            courses: [
                Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "张教授"),
                Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "李老师")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseEntry) -> Void) {
        let data = UserDefaults.init(suiteName: widgetGroupId)
        
        let title = data?.string(forKey: "flutter.title") ?? "今日课表"
        let dateStr = data?.string(forKey: "flutter.date") ?? ""
        
        var courses: [Course] = []
        if let coursesData = data?.string(forKey: "flutter.courses"),
           let coursesJson = try? JSONSerialization.jsonObject(with: coursesData.data(using: .utf8)!) as? [[String: Any]] {
            courses = coursesJson.compactMap { Course.fromJson($0) }
        }
        
        let entry = CourseEntry(date: Date(), title: title, dateString: dateStr, courses: courses)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let location: String
    let teacher: String
    
    static func fromJson(_ json: [String: Any]) -> Course? {
        guard let title = json["title"] as? String,
              let time = json["time"] as? String,
              let location = json["location"] as? String,
              let teacher = json["teacher"] as? String else {
            return nil
        }
        
        return Course(title: title, time: time, location: location, teacher: teacher)
    }
}

struct CourseEntry: TimelineEntry {
    let date: Date
    let title: String
    let dateString: String
    let courses: [Course]
    
    init(date: Date, title: String, dateString: String = "", courses: [Course] = []) {
        self.date = date
        self.title = title
        self.dateString = dateString
        self.courses = courses
    }
}

struct TodayCoursesWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if !entry.dateString.isEmpty {
                        Text(entry.dateString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
            
            // Course list or empty state
            if entry.courses.isEmpty {
                VStack(alignment: .center, spacing: 4) {
                    Text("今天没有课程")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("享受你的自由时光吧！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(entry.courses) { course in
                            CourseRowView(course: course)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(course.title)
                .font(.body)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text(course.time)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                Text(course.location)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(course.teacher)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TodayCoursesWidget: Widget {
    let kind: String = "TodayCoursesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayCoursesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日课表")
        .description("查看今天的课程安排")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayCoursesWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayCoursesWidgetEntryView(
            entry: CourseEntry(
                date: Date(),
                title: "今日课表",
                dateString: "第12周 周三",
                courses: [
                    Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "张教授"),
                    Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "李老师"),
                    Course(title: "计算机科学", time: "第5-6节 14:00-15:30", location: "实验楼C301", teacher: "王博士")
                ]
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}