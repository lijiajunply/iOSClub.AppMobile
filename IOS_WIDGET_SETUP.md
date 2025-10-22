# iOS 小组件设置指南

## 文件结构

我们已经为您创建了所有必需的小组件文件：
- `ios/HomeWidgetTodayCourses/Info.plist` - 小组件的基本配置
- `ios/HomeWidgetTodayCourses/TodayCoursesWidget.swift` - 小组件的主要Swift代码
- `ios/HomeWidgetTodayCourses/Assets.xcassets` - 小组件的资源文件

## 在Xcode中配置小组件

### 1. 添加小组件目标

1. 打开 `ios/Runner.xcworkspace`（不是`Runner.xcodeproj`）
2. 在项目导航器中右键点击项目根节点（iOS Club App）
3. 选择 `New Target...`
4. 在弹出的窗口中搜索 "Widget"
5. 选择 `Widget Extension` 并点击 `Next`
6. 填写以下信息：
   - Product Name: `TodayCoursesWidget`
   - Team: 选择您的开发团队（如果没有，请先创建Apple Developer Account）
   - Deployment Info:
     - iOS版本: 14.0 或更高
7. 点击 `Finish`
8. 如果出现选项 "Would you like to activate the scheme?", 选择 `Cancel`

### 2. 替换自动生成的文件

1. 在项目导航器中展开 `TodayCoursesWidget` 文件夹
2. 选择并删除自动生成的 `TodayCoursesWidget.swift` 文件
3. 将 `ios/HomeWidgetTodayCourses/TodayCoursesWidget.swift` 文件拖拽到 `TodayCoursesWidget` 文件夹中
4. 确保在弹出的对话框中选择 "Copy items if needed" 和 "Add to targets"（TodayCoursesWidget 应该被选中）

### 3. 配置App Groups

1. 在项目导航器中选择 `Runner` 项目
2. 选择 `Runner` 目标
3. 点击 `Signing & Capabilities` 标签
4. 点击左上角的 `+ Capability` 按钮
5. 搜索并双击 `App Groups`
6. 点击 App Groups 区域中的 `+` 按钮
7. 添加一个新的 App Group: `group.com.example.iosClubApp.widget`
8. 对 `TodayCoursesWidget` 目标重复步骤3-7

### 4. 测试小组件

1. 选择 `Runner` scheme 并在iOS设备或模拟器上运行应用
2. 回到主屏幕，长按空白区域进入编辑模式
3. 点击左下角的 `+` 按钮
4. 搜索并选择 "今日课表"
5. 选择合适的尺寸并添加到主屏幕

## 故障排除

### 如果小组件不显示数据：

1. 确保在主应用中已经获取了课程数据
2. 确保App Groups配置正确且一致
3. 检查设备的小组件访问权限设置

### 如果遇到编译错误：

1. 清理项目：`Product` > `Clean Build Folder` (Cmd+Shift+K)
2. 重新构建项目
3. 确保所有文件都已正确添加到目标中

## 注意事项

- 小组件在iOS 14.0及以上版本可用
- 小组件的数据刷新依赖于主应用调用更新方法
- 在iOS模拟器上测试时，可能需要等待几分钟才能看到数据更新
- 小组件的UI是用SwiftUI编写的，支持深色模式