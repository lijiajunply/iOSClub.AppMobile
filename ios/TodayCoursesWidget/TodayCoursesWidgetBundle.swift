//
//  TodayCoursesWidgetBundle.swift
//  TodayCoursesWidget
//
//  Created by 李嘉俊 on 2025/10/22.
//

import WidgetKit
import SwiftUI

@main
struct TodayCoursesWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayCoursesWidget()
        TodayCoursesWidgetControl()
        TodayCoursesWidgetLiveActivity()
    }
}
