# 状态管理重构说明

为了更好地组织代码和实现关注点分离，我们对项目进行了重构，将状态管理部分移到了 `stores` 目录中。

## 重构目标

1. **stores** - 状态管理（使用GetX）
2. **services** - 数据处理逻辑
3. **net** - 网络交互相关代码

## 已完成的工作

1. 创建了统一的 SharedPreferences 键管理文件 [prefs_keys.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/prefs_keys.dart)
2. 创建了基础的 Store 示例：
   - [user_store.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/user_store.dart) - 用户状态管理
   - [course_store.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/course_store.dart) - 课程状态管理
   - [settings_store.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/settings_store.dart) - 设置状态管理
   - [schedule_store.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/schedule_store.dart) - 课表状态管理
3. 创建了 Store 初始化和释放的管理文件 [init.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/init.dart)
4. 更新了 [main.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/main.dart) 文件以初始化 stores
5. 更新了以下页面以使用新的状态管理：
   - [about_page.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/pages/about_page.dart) - 使用 SettingsStore 管理设置状态
   - [schedule_list_page.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/pages/schedule_list_page.dart) - 使用 ScheduleStore 管理课表状态

## 使用方法

1. 在应用启动时调用 `initStores()` 初始化所有 Store
2. 在需要的地方通过 `StoreName.to` 访问对应的 Store 实例
3. Store 会自动管理状态并在 UI 中响应变化

## 示例

```dart
// 初始化
initStores();

// 使用
final userStore = UserStore.to;
print(userStore.isLogin);

// 更新状态
userStore.setUserData(userData);
```

## 下一步计划

1. 逐步将现有的状态管理迁移到 stores 目录中
2. 统一使用 GetX 进行状态管理
3. 优化现有代码结构，确保符合关注点分离原则