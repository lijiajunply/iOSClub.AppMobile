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

func extractDateInfo(from dateString: String) -> (day: String, weekday: String) {
    let components = dateString.split(separator: " ")
    var day = "27"
    var weekday = "星期一"

    if components.count >= 1 {
        let dateComponent = String(components[0])
        if let range = dateComponent.range(of: "\\d+", options: .regularExpression) {
            day = String(dateComponent[range])
        }
    }

    if components.count >= 2 {
        weekday = String(components[1])
    }

    return (day, weekday)
}

struct TomorrowCoursesWidgetEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry

    let accentColor = Color(red: 0.7, green: 0.4, blue: 0.9)
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                // TabView：滑动标签页
                TabView(selection: $selectedTab) {
                    // 今天
                    CoursesPanelView(
                        title: "今天",
                        courses: entry.todayCourses,
                        accentColor: accentColor,
                        colorScheme: colorScheme
                    )
                    .tag(0)

                    // 明天
                    CoursesPanelView(
                        title: "明天",
                        courses: entry.tomorrowCourses,
                        accentColor: accentColor,
                        colorScheme: colorScheme
                    )
                    .tag(1)
                }
#if os(macOS)
                .frame(height: 180)
#else
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 180)
#endif
            }
            .padding(12)
        }
    }
}

struct CoursesPanelView: View {
    let title: String
    let courses: [Course]
    let accentColor: Color
    let colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题
            Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)

            if !courses.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(courses) { course in
                            CourseRowView(course: course, accentColor: accentColor, colorScheme: colorScheme)
                        }
                    }
                    .padding(.horizontal, 10)
                }
            } else {
                EmptyCoursesView(text: "\(title)无课程")
            }
        }
    }
}

struct CourseRowView: View {
    let course: Course
    let accentColor: Color
    let colorScheme: ColorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // 左侧紫色竖条
            RoundedRectangle(cornerRadius: 2)
            .fill(accentColor)
            .frame(width: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text(course.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

                Text(course.time)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.75) : Color(red: 0.6, green: 0.6, blue: 0.65))
                .lineLimit(1)

                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                        .font(.caption2)
                        Text(course.location)
                        .font(.caption2)
                    }
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.75) : Color(red: 0.6, green: 0.6, blue: 0.65))
                    .lineLimit(1)

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "person.fill")
                        .font(.caption2)
                        Text(course.teacher)
                        .font(.caption2)
                    }
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.75) : Color(red: 0.6, green: 0.6, blue: 0.65))
                    .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.17) : Color(red: 0.95, green: 0.95, blue: 0.98))
        )
    }
}

struct EmptyCoursesView: View {
    let text: String

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)

            Text("✨ 享受自由时光")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .background(
            RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.1))
        )
    }
}

struct TomorrowCoursesWidget: Widget {
    let kind: String = "TomorrowCoursesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TomorrowCoursesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("近日课表")
        .description("查看今天和明天的课程安排")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}