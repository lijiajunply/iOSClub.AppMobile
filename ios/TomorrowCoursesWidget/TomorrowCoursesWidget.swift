import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CourseEntry {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        
        let todayDateString = "\(dateFormatter.string(from: today)) \(weekdayFormatter.string(from: today))"
        let tomorrowDateString = "\(dateFormatter.string(from: tomorrow)) \(weekdayFormatter.string(from: tomorrow))"
        
        return CourseEntry(
            date: today,
            title: "近日课表",
            todayDateString: todayDateString,
            tomorrowDateString: tomorrowDateString,
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
        let todayStr = data?.string(forKey: "flutter.tomorrow.date") ?? getCurrentDateString()
        let tomorrowStr = data?.string(forKey: "flutter.tomorrow.tomorrowDate") ?? getTomorrowDateString()

        var todayCourses: [Course] = []
        if let coursesData = data?.string(forKey: "flutter.tomorrow.courses"),
           let coursesData = coursesData.data(using: .utf8),
           let coursesJson = try? JSONSerialization.jsonObject(with: coursesData) as? [[String: Any]] {
            todayCourses = coursesJson.compactMap { Course.fromJson($0) }
        }

        var tomorrowCourses: [Course] = []
        if let coursesData = data?.string(forKey: "flutter.tomorrow.tomorrowCourses"),
           let coursesData = coursesData.data(using: .utf8),
           let coursesJson = try? JSONSerialization.jsonObject(with: coursesData) as? [[String: Any]] {
            tomorrowCourses = coursesJson.compactMap { Course.fromJson($0) }
        }

        let entry = CourseEntry(date: Date(), title: title, todayDateString: todayStr, tomorrowDateString: tomorrowStr, todayCourses: todayCourses, tomorrowCourses: tomorrowCourses)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(in: context) { (entry) in
            // 设置下一次更新时间为1小时后
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        return formatter.string(from: Date())
    }
    
    private func getTomorrowDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatter.string(from: tomorrow)
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

    // 使用系统默认的强调色，更符合苹果设计风格
    let accentColor = Color(.systemBlue)
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                // 标题栏
                HStack {
                    Text(entry.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                // 显示当前日期信息
                HStack {
                    Text(extractDateInfo(from: entry.todayDateString).day)
                        .font(.caption)
                        .foregroundColor(Color.gray.opacity(0.7))
                    Text(extractDateInfo(from: entry.todayDateString).weekday)
                        .font(.caption)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                
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
                // 隐藏分页指示器，更简约
                .onAppear {
                    UIPageControl.appearance().isHidden = false
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(accentColor)
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray3
                }
#endif
            }
            .padding(12)
        }
        // 添加点击交互，点击后打开应用
        .widgetURL(URL(string: "iosclubapp://courses"))
    }
}

struct CoursesPanelView: View {
    let title: String
    let courses: [Course]
    let accentColor: Color
    let colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !courses.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(courses) { course in
                            CourseRowView(course: course, accentColor: accentColor, colorScheme: colorScheme)
                        }
                    }
                }
            } else {
                EmptyCoursesView(text: "\(title)无课程")
                    .frame(maxHeight: .infinity)
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
            // 左侧强调色竖条，更细更符合苹果风格
            RoundedRectangle(cornerRadius: 1)
                .fill(accentColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(course.time)
                    .font(.caption)
                    .foregroundColor(Color.gray.opacity(0.7))
                    .lineLimit(1)

                HStack(alignment: .center, spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption2)
                            .foregroundColor(Color.gray.opacity(0.6))
                        Text(course.location)
                            .font(.caption2)
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                    .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "person")
                            .font(.caption2)
                            .foregroundColor(Color.gray.opacity(0.6))
                        Text(course.teacher)
                            .font(.caption2)
                    }
                    .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        // 添加轻微的阴影效果
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

struct EmptyCoursesView: View {
    let text: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 24))
                .padding(.bottom, 4)
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("享受自由时光")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
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
        .supportedFamilies([.systemMedium])
    }
}