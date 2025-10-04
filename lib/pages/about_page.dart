import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/Services/todo_service.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'package:ios_club_app/Services/edu_service.dart';
import 'package:ios_club_app/Services/git_service.dart';
import 'package:ios_club_app/Services/notification_service.dart';
import 'package:ios_club_app/services/download_service.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/stores/user_store.dart';
import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/platform_dialog.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                  const RemindSetting(),
                  const TodoListSetting(),
                  const HomePageSetting(),
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
                _buildSectionTitle('小组件', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildWidgetTile(context, isDark),
                ]),
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

// 更新 ShowTomorrowSetting 组件
class ShowTomorrowSetting extends StatefulWidget {
  const ShowTomorrowSetting({super.key});

  @override
  State<StatefulWidget> createState() => _ShowTomorrowSettingState();
}

class _ShowTomorrowSettingState extends State<ShowTomorrowSetting> {
  late bool isShowTomorrow = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isShowTomorrow = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 20,
            color: CupertinoColors.systemPurple,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '显示明日课程',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '当今日无课时显示明日课程',
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
          CupertinoSwitch(
            value: isShowTomorrow,
            onChanged: (bool value) async {
              setState(() {
                isShowTomorrow = value;
              });
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool(PrefsKeys.IS_REMIND, value);
            },
          ),
        ],
      ),
    );
  }
}

class RemindSetting extends StatefulWidget {
  const RemindSetting({super.key});

  @override
  State<StatefulWidget> createState() => _RemindSettingState();
}

class _RemindSettingState extends State<RemindSetting> {
  late bool isRemind = false;
  late int remindTime = 15;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isRemind = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
        remindTime = prefs.getInt(PrefsKeys.NOTIFICATION_TIME) ?? 15;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '课程通知',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '上课前进行提醒',
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
                CupertinoSwitch(
                  value: isRemind,
                  onChanged: (bool value) async {
                    setState(() {
                      isRemind = value;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool(PrefsKeys.IS_REMIND, value);
                    if (value && context.mounted) {
                      await NotificationService.set(context);
                    }
                  },
                )
              ],
            )),
        if (isRemind)
          Material(
            color: Colors.transparent,
            child: InkWell(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '提前几分钟提醒',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Text('$remindTime分钟')
                    ],
                  ),
                ),
                onTap: () {
                  _show(context);
                }),
          ),
      ],
    );
  }

  Future<void> _show(BuildContext context) async {
    final a = MediaQuery.of(context).size.width;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: a,
        minWidth: a,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberPicker(
                    value: remindTime,
                    minValue: 10,
                    maxValue: 120,
                    step: 1,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt(PrefsKeys.NOTIFICATION_TIME, value);
                      setStateBottomSheet(() {
                        remindTime = value;
                      });
                      // 可选：更新主页面的 remindTime
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class VersionSetting extends StatefulWidget {
  const VersionSetting({super.key});

  @override
  State<StatefulWidget> createState() => _VersionSettingState();
}

class _VersionSettingState extends State<VersionSetting> {
  late bool updateIgnored = false;
  late bool isNeedUpdate = false;
  late String version = '';
  late String newVersion = '';

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        version = packageInfo.version;
        SharedPreferences.getInstance().then((prefs) {
          updateIgnored = prefs.getBool(PrefsKeys.UPDATE_IGNORED) ?? false;
        });
        GiteeService.isNeedUpdate().then((res) {
          isNeedUpdate = res.$1;
          if (res.$1) {
            newVersion = res.$2.name;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    isNeedUpdate
                        ? Badge(
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.update,
                              size: 20,
                            ),
                          )
                        : Icon(Icons.verified, size: 20, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '版本',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(version,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                if (isNeedUpdate) {
                  final result = await PlatformDialog.showConfirmDialog(
                    context,
                    title: '是否更新最新版本: $newVersion',
                    content: '发现新版本可用，是否立即更新？',
                    confirmText: '是的',
                    cancelText: '不要',
                  );

                  if (result == true) {
                    final a = await GiteeService.getReleases();
                    if (context.mounted) {
                      UpdateManager.showUpdateWithProgress(context, a.name);
                    }
                  }
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.update,
                size: 20,
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '更新日志',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '忽略版本更新',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: updateIgnored,
                onChanged: (bool value) async {
                  setState(() {
                    updateIgnored = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(PrefsKeys.UPDATE_IGNORED, value);
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TodoListSetting extends StatefulWidget {
  const TodoListSetting({super.key});

  @override
  State<StatefulWidget> createState() => _TodoListSettingState();
}

class _TodoListSettingState extends State<TodoListSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.cloud_upload_fill,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '是否将待办保存至云端',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '将待办事务保存至社团官网',
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
            Obx(() => CupertinoSwitch(
                  value: settingsStore.isUpdateToClub,
                  onChanged: (bool value) async {
                    await settingsStore.setIsUpdateToClub(value);
                    if (value) {
                      await TodoService.nowToUpdate();
                    }
                  },
                ))
          ],
        ));
  }
}

class HomePageSetting extends StatefulWidget {
  const HomePageSetting({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageSettingState();
}

class _HomePageSettingState extends State<HomePageSetting> {
  int _pageIndex = 0;
  final List<String> _pageNames = [
    '首页',
    '课程页',
    '成绩页',
    '个人页',
  ];

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _pageIndex = prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Icon(
                  Icons.pageview,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '打开应用的第一个页面',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Text(_pageNames[_pageIndex]),
                const SizedBox(width: 4),
              ],
            )),
        onTap: () => showClubModalBottomSheet(
          context,
          SizedBox(
            height: 200, // 给 CupertinoPicker 固定高度
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32.0,
              scrollController:
                  FixedExtentScrollController(initialItem: _pageIndex),
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _pageIndex = selectedItem;
                });
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setInt(PrefsKeys.PAYMENT_NUM, selectedItem);
                });
              },
              children: List.generate(_pageNames.length, (int index) {
                return Center(child: Text(_pageNames[index]));
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> gradientColors;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.gradientColors = const [
      Color(0xFFF9BF65),
      Color(0xFFFFAB6B),
      Color(0xFFFC8986),
      Color(0xFFEF7E95),
      Color(0xFFBF83C1),
      Color(0xFFAB8DCF),
      Color(0xFF7FA0DC),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          transform: const GradientRotation(-64 * 3.14159 / 180), // 转换角度为弧度
          colors: gradientColors,
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // 使用白色作为基础颜色
      ),
    );
  }
}
