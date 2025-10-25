import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ios_club_app/net/git_service.dart';

/// 更新管理类
///
/// 支持两种更新机制：
/// 1. Gitee 发行版更新机制（默认）
/// 2. 应用商店更新机制（通过环境变量或.env文件启用）
///
/// 使用方式：
/// 1. 设置环境变量 UPDATE_CHANNEL=appstore
/// 2. 或在.env文件中设置 UPDATE_CHANNEL=appstore
class CheckUpdateManager {
  /// 初始化更新管理器
  ///
  /// 加载.env配置文件
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // 如果.env文件不存在，则忽略错误
      debugPrint("未找到.env文件: $e");
    }
  }

  /// 检查是否应该执行更新检查
  ///
  /// 检查顺序：
  /// 1. 系统环境变量
  /// 2. .env文件配置
  ///
  /// 当 UPDATE_CHANNEL 设置为 'appstore' 时，
  /// 应用将跳过更新检查，适用于通过应用商店分发的版本
  static bool shouldCheckForUpdates() {
    // 在Web平台上总是不检查更新（使用Docker自更新）
    // 在iOS、MacOS、Windows平台中不更新（使用各平台的App Store）
    if (kIsWeb || Platform.isIOS || Platform.isMacOS || Platform.isWindows) return false;
    
    // 首先检查系统环境变量
    final envUpdateChannel = Platform.environment['UPDATE_CHANNEL'];
    if (envUpdateChannel == 'appstore') {
      return false;
    }
    
    // 然后检查.env文件中的配置
    // 添加对 dotenv 是否已初始化的检查
    try {
      final dotenvUpdateChannel = dotenv.maybeGet('UPDATE_CHANNEL');
      if (dotenvUpdateChannel == 'appstore') {
        return false;
      }
    } catch (e) {
      // 如果 dotenv 未初始化则忽略
      debugPrint("DotEnv 未初始化: $e");
    }
    
    // 默认情况下检查更新
    return true;
  }

  /// 获取更新检查服务
  ///
  /// 根据环境变量决定返回哪种更新服务
  static Future<(bool, ReleaseModel)> checkForUpdates() async {
    if (shouldCheckForUpdates()) {
      return await GiteeService.isNeedUpdate();
    } else {
      // 返回不需要更新的结果
      return (false, ReleaseModel(name: '0.0.0', body: '0.0.0'));
    }
  }
}