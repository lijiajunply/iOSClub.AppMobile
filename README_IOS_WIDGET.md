# iOS 小组件集成指南

## 概述

本指南说明如何在iOS Club App中集成今日课程小组件。

## 文件结构

我们已经为您创建了所有必需的小组件文件：
- `ios/HomeWidgetTodayCourses/Info.plist` - 小组件的基本配置
- `ios/HomeWidgetTodayCourses/TodayCoursesWidget.swift` - 小组件的主要Swift代码
- `ios/HomeWidgetTodayCourses/Assets.xcassets` - 小组件的资源文件

## 手动集成步骤

### 1. 在Xcode中添加小组件目标

1. 打开 `ios/Runner.xcworkspace` 文件（注意：不是Runner.xcodeproj）
2. 在项目导航器中选择项目根节点
3. 点击菜单栏 `File` > `New` > `Target...`
4. 选择 `Widget Extension` 并点击 `Next`
5. 填写以下信息:
   - Product Name: `TodayCoursesWidget`
   - Team: 选择你的开发团队
   - Deployment Info:
     - iOS版本: 14.0 或更高
6. 点击 `Finish`

### 2. 配置小组件

1. 将以下文件复制到新创建的小组件目标中:
   - `ios/HomeWidgetTodayCourses/TodayCoursesWidget.swift`
   - `ios/HomeWidgetTodayCourses/Info.plist`
   - `ios/HomeWidgetTodayCourses/Assets.xcassets` 文件夹

2. 替换自动生成的文件内容:
   - 用 `TodayCoursesWidget.swift` 的内容替换自动生成的文件内容

### 3. 配置App Groups

1. 在Xcode中选择Runner主应用目标
2. 点击 `Signing & Capabilities`
3. 点击 `+ Capability` 并添加 `App Groups`
4. 添加一个新的App Group，命名为: `group.com.example.iosClubApp.widget`
5. 对小组件目标重复上述步骤3和4

### 4. 修改主应用代码

确保在主应用中使用正确的小组件名称更新数据:

```dart
// 在 lib/system_services/widget_service.dart 中
await HomeWidget.updateWidget(
  name: appWidgetProviderClass,
  androidName: 'TodayCoursesWidgetProvider',
  iosName: 'TodayCoursesWidget',
  qualifiedAndroidName: 'com.example.ios_club_app.TodayCoursesWidgetProvider',
);
```

### 5. 测试小组件

1. 构建并运行应用到iOS设备或模拟器
2. 长按主屏幕，选择添加小组件
3. 搜索并添加 "今日课表" 小组件

## 注意事项

- 小组件在iOS 14.0及以上版本可用
- 小组件的数据通过App Groups在主应用和小组件之间共享
- 小组件的刷新依赖于主应用调用 `updateWidget` 方法
- 在iOS模拟器上测试时，可能需要等待几分钟才能看到数据更新