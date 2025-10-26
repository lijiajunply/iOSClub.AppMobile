//
//  AppIntent.swift
//  TomorrowCoursesWidget
//
//  Created by 李嘉俊 on 2025/10/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "课表配置" }
    static var description: IntentDescription { "配置课表小组件的显示选项" }

    // 显示选项：今天、明天或两者都显示
    @Parameter(title: "显示选项", 
               description: "选择要在小组件中显示的课程日期", 
               default: .both) 
    var displayOption: DisplayOption
    
    // 刷新频率选项
    @Parameter(title: "刷新频率", 
               description: "设置课表数据的自动刷新频率", 
               default: .hourly) 
    var refreshFrequency: RefreshFrequency
}

// 显示选项枚举
enum DisplayOption: String, AppEnum {
    case today
    case tomorrow
    case both
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "显示选项")
    
    static var caseDisplayRepresentations: [Self : DisplayRepresentation] = [
        .today: "仅今天",
        .tomorrow: "仅明天",
        .both: "今天和明天"
    ]
}

// 刷新频率枚举
enum RefreshFrequency: String, AppEnum {
    case hourly
    case everyThreeHours
    case daily
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "刷新频率")
    
    static var caseDisplayRepresentations: [Self : DisplayRepresentation] = [
        .hourly: "每小时",
        .everyThreeHours: "每3小时",
        .daily: "每天"
    ]
    
    // 获取对应的时间间隔（秒）
    var timeInterval: TimeInterval {
        switch self {
        case .hourly:
            return 60 * 60 // 1小时
        case .everyThreeHours:
            return 3 * 60 * 60 // 3小时
        case .daily:
            return 24 * 60 * 60 // 24小时
        }
    }
}

// 刷新课表的Intent
struct RefreshCoursesIntent: AppIntent {
    static let title: LocalizedStringResource = "刷新课表"
    static let description = IntentDescription("立即刷新今日和明日的课程信息")
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // 刷新所有小组件时间线
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
