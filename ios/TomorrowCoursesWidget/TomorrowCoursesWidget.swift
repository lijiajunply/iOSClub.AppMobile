import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CourseEntry {
        CourseEntry(
            date: Date(),
            title: "今日明日课表",
            todayDateString: "今天",
            tomorrowDateString: "明天",
            todayCourses: [
                Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "张教授"),
                Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "李老师")
            ],
            tomorrowCourses: [
                Course(title: "计算机科学", time: "第1-2节 08:00-09:30", location: "实验楼C301", teacher: "王博士"),
                Course(title: "物理学", time: "第3-4节 10:00-11:30", location: "教学楼D405", teacher: "赵教授")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseEntry) -> Void) {
        let data = UserDefaults.init(suiteName: "group.com.example.iosClubApp.widget")
        
        let title = "近日课表"
        let todayStr = data?.string(forKey: "flutter.tomorrow.date") ?? ""
        let tomorrowStr = data?.string(forKey: "flutter.tomorrow.tomorrowDate") ?? ""
        
        var todayCourses: [Course] = []
        if let coursesData = data?.string(forKey: "flutter.tomorrow.courses"),
           let coursesJson = try? JSONSerialization.jsonObject(with: coursesData.data(using: .utf8)!) as? [[String: Any]] {
            todayCourses = coursesJson.compactMap { Course.fromJson($0) }
        }
        
        var tomorrowCourses: [Course] = []
        if let coursesData = data?.string(forKey: "flutter.tomorrow.tomorrowCourses"),
           let coursesJson = try? JSONSerialization.jsonObject(with: coursesData.data(using: .utf8)!) as? [[String: Any]] {
            tomorrowCourses = coursesJson.compactMap { Course.fromJson($0) }
        }
        
        let entry = CourseEntry(date: Date(), title: title, todayDateString: todayStr, tomorrowDateString: tomorrowStr, todayCourses: todayCourses, tomorrowCourses: tomorrowCourses)
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
    let todayDateString: String
    let tomorrowDateString: String
    let todayCourses: [Course]
    let tomorrowCourses: [Course]
    
    init(date: Date, title: String, todayDateString: String = "", tomorrowDateString: String = "", todayCourses: [Course] = [], tomorrowCourses: [Course] = []) {
        self.date = date
        self.title = title
        self.todayDateString = todayDateString
        self.tomorrowDateString = tomorrowDateString
        self.todayCourses = todayCourses
        self.tomorrowCourses = tomorrowCourses
    }
}

struct TomorrowCoursesWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if !entry.todayDateString.isEmpty {
                        Text(entry.todayDateString)
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
            
            // Course lists
            ScrollView(.vertical, showsIndicators: false) {
                // Today courses
                if !entry.todayCourses.isEmpty {
                    Text("今天")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(entry.todayCourses) { course in
                            CourseRowView(course: course)
                        }
                    }
                } else {
                    EmptyCoursesView(text: "今天无课程")
                }
                
                // Tomorrow courses
                if !entry.tomorrowCourses.isEmpty {
                    Text("明天")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(entry.tomorrowCourses) { course in
                            CourseRowView(course: course)
                        }
                    }
                } else {
                    EmptyCoursesView(text: "明天无课程")
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

struct EmptyCoursesView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(text)
                .font(.body)
                .fontWeight(.semibold)
            
            Text("享受你的自由时光吧！")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.vertical, 4)
    }
}

struct TomorrowCoursesWidget: Widget {
    let kind: String = "TomorrowCoursesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TomorrowCoursesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日明日课表")
        .description("查看今天和明天的课程安排")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
