//
//  TomorrowCoursesWidgetLiveActivity.swift
//  TomorrowCoursesWidget
//
//  Created by 李嘉俊 on 2025/10/25.
//

import WidgetKit
import SwiftUI

// 课程信息结构
struct CourseInfo: Codable, Hashable {
    let title: String
    let time: String
    let location: String
    let remainingMinutes: Int? // 距离上课剩余分钟数
}

// 为iOS平台定义LiveActivity（macOS不支持）
#if os(iOS)
import ActivityKit

struct TomorrowCoursesWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 当前课程信息
        var currentCourse: CourseInfo?
        // 下一节课信息
        var nextCourse: CourseInfo?
    }

    // 固定属性
    var studentName: String
}

struct TomorrowCoursesWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TomorrowCoursesWidgetAttributes.self) { context in
            // 锁屏/Banner界面
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("今日课程")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                if let currentCourse = context.state.currentCourse {
                    // 正在进行的课程
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("正在上课")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Text(currentCourse.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text(currentCourse.time)
                                    .font(.caption2)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "location")
                                    .font(.caption2)
                                Text(currentCourse.location)
                                    .font(.caption2)
                            }
                        }
                    }
                } else if let nextCourse = context.state.nextCourse {
                    // 即将开始的课程
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("即将开始")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            if let remainingMinutes = nextCourse.remainingMinutes {
                                Text("\(remainingMinutes)分钟后")
                                    .font(.caption2)
                                    .foregroundColor(Color.blue)
                            }
                            Spacer()
                        }
                        Text(nextCourse.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text(nextCourse.time)
                                    .font(.caption2)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "location")
                                    .font(.caption2)
                                Text(nextCourse.location)
                                    .font(.caption2)
                            }
                        }
                    }
                } else {
                    // 今天没有课程
                    VStack(alignment: .center) {
                        Text("今天没有课程")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(12)
            .activityBackgroundTint(Color.white)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // 扩展视图
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let currentCourse = context.state.currentCourse {
                            Text("正在上课")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(currentCourse.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        } else if let nextCourse = context.state.nextCourse {
                            Text("即将开始")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(nextCourse.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        if let course = context.state.currentCourse ?? context.state.nextCourse {
                            Text(course.time)
                                .font(.caption2)
                                .lineLimit(1)
                            Text(course.location)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Label("查看详情", systemImage: "info.circle")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            } compactLeading: {
                Image(systemName: context.state.currentCourse != nil ? "book.fill" : "calendar")
                    .foregroundColor(Color.blue)
            } compactTrailing: {
                if let course = context.state.currentCourse ?? context.state.nextCourse {
                    Text(course.title)
                        .font(.caption)
                        .lineLimit(1)
                } else {
                    Text("无课程")
                        .font(.caption)
                }
            } minimal: {
                Image(systemName: context.state.currentCourse != nil ? "book.fill" : "calendar")
                    .foregroundColor(Color.blue)
            }
            .widgetURL(URL(string: "iosclubapp://todaycourses"))
            .keylineTint(Color.blue)
        }
    }
}

extension TomorrowCoursesWidgetAttributes {
    fileprivate static var preview: TomorrowCoursesWidgetAttributes {
        TomorrowCoursesWidgetAttributes(studentName: "学生")
    }
}

extension TomorrowCoursesWidgetAttributes.ContentState {
    fileprivate static var currentCourse: TomorrowCoursesWidgetAttributes.ContentState {
        TomorrowCoursesWidgetAttributes.ContentState(
            currentCourse: CourseInfo(title: "高等数学", time: "08:00-09:30", location: "教学楼A101", remainingMinutes: nil),
            nextCourse: nil
        )
    }
    
    fileprivate static var nextCourse: TomorrowCoursesWidgetAttributes.ContentState {
        TomorrowCoursesWidgetAttributes.ContentState(
            currentCourse: nil,
            nextCourse: CourseInfo(title: "大学英语", time: "10:00-11:30", location: "教学楼B205", remainingMinutes: 15)
        )
    }
}

#Preview("当前课程", as: .content, using: TomorrowCoursesWidgetAttributes.preview) {   
   TomorrowCoursesWidgetLiveActivity()
} contentStates: {
    TomorrowCoursesWidgetAttributes.ContentState.currentCourse
    TomorrowCoursesWidgetAttributes.ContentState.nextCourse
}
#else
#endif
