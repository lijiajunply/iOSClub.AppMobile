# iOS Club App

这是一个基于 Flutter 的跨平台移动应用程序，专为 iOS Club 设计，旨在提供课程信息、日程安排、成员管理等功能。

## 主要功能

- **课程管理**：展示课程列表，包括课程名称、时间、地点等信息。
- **日程安排**：提供日程设置和展示功能。
- **成员管理**：展示俱乐部成员信息。
- **考试信息**：显示考试安排。
- **待办事项**：管理日常任务。
- **成绩查询**：查看个人成绩。
- **校园巴士信息**：提供校园巴士时刻表。
- **个人资料页面**：展示用户个人信息。
- **链接页面**：提供有用的外部链接。
- **其他功能**：包括电力图表、通知服务等。

## Android 特定功能

- **TodayCoursesWidgetProvider**：提供了一个 AppWidget，用于在 Android 桌面上显示当天的课程。
- **CourseListRemoteViewsService** 和 **CourseListRemoteViewsFactory**：支持 AppWidget 的远程视图服务和数据绑定。
- **暗色主题支持**：所有Android组件均支持暗色主题，能够根据系统设置自动适配亮色和暗色主题。

## 开发环境

- Flutter SDK
- Android Studio / Xcode（根据目标平台）
- Git

## 安装步骤

1. 确保你已经安装了 [Flutter SDK](https://flutter.dev/docs/get-started/install)。
2. 克隆仓库：
   ```bash
   git clone https://gitee.com/luckyfishisdashen/iOSClub.AppMobile.git
   ```
3. 进入项目目录：
   ```bash
   cd iOSClub.AppMobile
   ```
4. 获取依赖：
   ```bash
   flutter pub get
   ```
5. 运行应用：
   ```bash
   flutter run
   ```

## env注意

```env
# 可选值: 
# - gitee (默认，使用Gitee发行版更新)
# - appstore (应用商店版本，不检查更新)
UPDATE_CHANNEL=gitee
```

## 部署

1. Windows (msix):

   ```bash
   dart run msix:create --store
   ```

2. Android (apk):
   ```bash
   flutter build apk --obfuscate --split-debug-info=xx --no-tree-shake-icons --target-platform android-arm64 --split-per-abi
   ```

3. Web (wasm):

   ```bash
   flutter build web --no-tree-shake-icons --wasm
   ```

4. macOS

   ```bash
   flutter build macos
   ```

## 贡献指南

欢迎贡献代码和报告问题。请遵循以下步骤：

1. Fork 仓库。
2. 创建新分支。
3. 提交你的更改。
4. 创建 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。