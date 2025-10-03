# Stores

该目录用于存放使用 GetX 实现的状态管理 Store 类。

## 目录结构

```
stores/
├── init.dart          # Store 初始化和释放
├── prefs_keys.dart    # SharedPreferences 键统一管理
├── user_store.dart    # 用户状态管理
├── course_store.dart  # 课程状态管理
├── schedule_store.dart # 课表状态管理
├── settings_store.dart # 设置状态管理
└── ...                # 其他业务状态管理
```

## 使用说明

1. 所有 Store 类应继承自 GetX 的 `GetxController`
2. 在应用启动时调用 `initStores()` 初始化所有 Store
3. 在应用退出时调用 `disposeStores()` 释放所有 Store
4. 通过 `StoreName.to` 访问对应的 Store 实例

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

## 约定

1. Store 类名以 `_store.dart` 结尾
2. 使用 GetX 的响应式状态管理（`.obs`）
3. 统一使用 [prefs_keys.dart](file:///C:/Projects/FlutterProjects/ios_club_app/lib/stores/prefs_keys.dart) 管理 SharedPreferences 的键
4. 网络请求放在 `../net/` 目录中
5. 数据处理逻辑放在 `../services/` 目录中