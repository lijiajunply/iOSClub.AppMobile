# 测试说明

本项目包含单元测试和小部件测试，用于确保代码质量和功能正确性。

## 测试结构

```
test/
├── unit/                    # 单元测试
│   ├── course_model_test.dart
│   ├── score_model_test.dart
│   ├── course_store_test.dart
│   └── turnover_analyzer_test.dart
├── widget/                  # 小部件测试
│   ├── empty_widget_test.dart
│   ├── club_card_test.dart
│   └── show_club_snack_bar_test.dart
├── all_tests.dart           # 所有测试的聚合文件
└── widget_test.dart         # 主测试文件
```

## 运行测试

### 运行所有测试

```bash
flutter test
```

### 运行特定测试文件

```bash
flutter test test/unit/course_model_test.dart
flutter test test/widget/empty_widget_test.dart
```

### 查看测试覆盖率

```bash
flutter test --coverage
```

## 测试类型

### 单元测试

单元测试主要针对模型类、服务类和存储类等业务逻辑进行测试，确保数据处理和计算的正确性。

### 小部件测试

小部件测试主要针对UI组件进行测试，确保组件能够正确显示和响应用户交互。

## 编写新测试

1. 根据测试类型将测试文件放在相应的目录中
2. 使用`test`函数进行单元测试，使用`testWidgets`函数进行小部件测试
3. 确保测试覆盖各种边界情况和错误情况
4. 将新测试添加到`all_tests.dart`文件中，以便统一运行

## 测试最佳实践

1. 每个测试应该只测试一个功能点
2. 测试应该独立于其他测试运行
3. 使用描述性的测试名称
4. 在测试中模拟外部依赖
5. 确保测试覆盖率尽可能高