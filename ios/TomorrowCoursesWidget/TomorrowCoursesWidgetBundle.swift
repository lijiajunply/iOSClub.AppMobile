//
//  TomorrowCoursesWidgetBundle.swift
//  TomorrowCoursesWidget
//
//  Created by 李嘉俊 on 2025/10/25.
//

import WidgetKit
import SwiftUI

@main
struct TomorrowCoursesWidgetBundle: WidgetBundle {
    var body: some Widget {
        TomorrowCoursesWidget()
        TomorrowCoursesWidgetControl()
        TomorrowCoursesWidgetLiveActivity()
    }
}
