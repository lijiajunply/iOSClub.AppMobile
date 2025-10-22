import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'package:ios_club_app/net/edu_service.dart';
import 'package:ios_club_app/stores/user_store.dart';
import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/platform_dialog.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../widgets/settingPages/show_tomorrow_setting.dart';
import '../widgets/settingPages/remind_setting.dart';
import '../widgets/settingPages/version_setting.dart';
import '../widgets/settingPages/todo_list_setting.dart';
import '../widgets/settingPages/home_page_setting.dart';
import '../widgets/settingPages/gradient_icon.dart';
import '../widgets/settingPages/haptic_feedback_setting.dart';
import '../widgets/settingPages/font_family_setting.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userStore = Get.find<UserStore>();

    return Scaffold(
      appBar: ClubAppBar(
        title: '设置',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final horizontalPadding = isTablet ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // App 图标区域
                _buildAppHeader(context, isDark),
                const SizedBox(height: 32),
                // 基本设置
                _buildSectionTitle('基本设置', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildRefreshTile(context, isDark),
                  const ShowTomorrowSetting(),
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                    const RemindSetting(),
                  const TodoListSetting(),
                  const HomePageSetting(),
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                    const HapticFeedbackSetting(), // 添加触觉反馈设置
                  if (!kIsWeb && (Platform.isWindows || Platform.isLinux))
                    const FontFamilySetting(), // 添加字体设置
                ]),
                const SizedBox(height: 24),
                // 版本信息
                _buildSectionTitle('版本', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  const VersionSetting(),
                ]),
                const SizedBox(height: 24),
                // 安卓小组件
                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                  _buildSectionTitle('小组件', isDark),
                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                  const SizedBox(height: 12),
                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                  _buildSettingsGroup([
                    _buildWidgetTile(context, isDark),
                  ]),
                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                  const SizedBox(height: 24),
                // 关于我们
                _buildSectionTitle('关于', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildTeamTile(isDark),
                  _buildLicenseTile(isDark),
                  _buildClubTile(context, isDark),
                ]),
                const SizedBox(height: 24),
                // 关于我们
                _buildSectionTitle('其他', isDark),
                const SizedBox(height: 12),
                Obx(() {
                  return _buildSettingsGroup([
                    if (userStore.isLogin) _buildLogoutTile(context, isDark),
                    if (userStore.isLoginMember)
                      _buildLogoutMemberTile(context, isDark),
                  ]);
                }),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: const Image(
              image: AssetImage('assets/icon.webp'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'iOS Club App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '试着把建大囊括其中',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : CupertinoColors.secondaryLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return ClubCard(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRefreshTile(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          showClubSnackBar(context, const Text('正在刷新数据...'));
          final re = await EduService.refresh();
          if (context.mounted) {
            showClubSnackBar(context, Text('刷新数据${re ? '成功' : '失败'}'));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.refresh,
                size: 20,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '刷新数据',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : CupertinoColors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTile(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.person_2_fill,
            size: 20,
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '制作团队',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'LuckyFish & zealous',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseTile(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.doc_text_fill,
            size: 20,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '开源协议',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'MIT License',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubTile(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showClubDescription(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GradientIcon(
                size: 20,
                icon: Icons.apple,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '关于社团',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'iOS Club of XAUAT',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : CupertinoColors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClubDescription(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showClubModalBottomSheet(
        context,
        Column(
          children: [
            Text(
              '关于社团',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const Image(
                  image: AssetImage('assets/iOS_Club_Logo.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'iOS Club of XAUAT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '西建大iOS众创空间俱乐部（别称为西建大iOS Club），是苹果公司和学校共同创办的创新创业类社团。成立于2019年9月。目前是全校较大和较为知名的科技类社团。',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '西建大iOS众创空间俱乐部没有设备要求，或者说没有任何限制 —— 只要你喜欢数码，热爱编程，或者想要学习编程开发搞项目，就可以加入到西建大iOS众创空间俱乐部。',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildLogoutTile(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final result = await PlatformDialog.showConfirmDialog(
            context,
            title: "确定退出登录吗？",
            content: "退出后需要重新登录才能访问教务系统数据",
            confirmText: '退出登录',
            cancelText: '取消',
          );

          if (result == true) {
            final userStore = Get.find<UserStore>();
            await userStore.logout();
            Get.toNamed("Profile");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                size: 20,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : CupertinoColors.tertiaryLabel,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '退出教务系统',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMemberTile(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final result = await PlatformDialog.showConfirmDialog(
            context,
            title: "确定退出登录吗？",
            content: "退出后需要重新登录才能访问数据",
            confirmText: '退出登录',
            cancelText: '取消',
          );

          if (result == true) {
            final userStore = Get.find<UserStore>();
            await userStore.logoutMember();
            if (context.mounted) {
              showClubSnackBar(context, const Text('已退出iMember账号'));
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                size: 20,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : CupertinoColors.tertiaryLabel,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '退出iMember',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetTile(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // 直接打开安卓小组件设置
          _openWidgetSettings(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(
                Icons.widgets,
                size: 20,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '添加到桌面',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : CupertinoColors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openWidgetSettings(BuildContext context) async {
    try {
      // 尝试直接打开小组件设置页面
      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'android.settings.ACTION_APPLICATION_DETAILS_SETTINGS',
          data: Uri.encodeFull('package: com.example.ios_club_app'),
        );
        await intent.launch();
      }
    } catch (e) {
      // 如果无法直接打开设置，则显示说明
      if (context.mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        _showWidgetInstructions(context, isDark);
      }
    }
  }

  void _showWidgetInstructions(BuildContext context, bool isDark) {
    showClubModalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '添加小组件到桌面',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '请按照以下步骤操作：',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            isDark,
            '1',
            '长按手机桌面空白处',
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            isDark,
            '2',
            '点击"小组件"或"Widgets"选项',
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            isDark,
            '3',
            '找到"iOS Club App"并选择合适的小组件',
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            isDark,
            '4',
            '将小组件拖拽到桌面合适位置',
          ),
          const SizedBox(height: 24),
          Text(
            '提示：小组件可以显示今日课程等信息，方便快速查看',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(bool isDark, String step, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}