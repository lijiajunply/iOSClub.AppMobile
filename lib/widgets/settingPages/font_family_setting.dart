import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/widgets/club_modal_bottom_sheet.dart';

// 添加字体设置组件
class FontFamilySetting extends StatefulWidget {
  const FontFamilySetting({super.key});

  @override
  State<FontFamilySetting> createState() => _FontFamilySettingState();
}

class _FontFamilySettingState extends State<FontFamilySetting> {
  final SettingsStore settingsStore = SettingsStore.to;
  final List<String> _fontOptions = [
    '',
    'Arial',
    'Roboto',
    'San Francisco',
    'Segoe UI',
    '微软雅黑',
    'Microsoft YaHei',
    'PingFang SC',
    'Helvetica Neue',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Icon(
                  Icons.font_download,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '字体设置',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '为桌面平台选择字体(下次打开时才会应用)',
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
                Obx(() => Text(_fontOptions.contains(settingsStore.fontFamily)
                    ? settingsStore.fontFamily.isEmpty
                        ? '系统默认'
                        : settingsStore.fontFamily
                    : '自定义')),
                const SizedBox(width: 4),
              ],
            )),
        onTap: () => showClubModalBottomSheet(
          context,
          SizedBox(
            height: 300,
            child: Obx(() => CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                      initialItem: _fontOptions.indexWhere(
                          (element) => element == settingsStore.fontFamily)),
                  onSelectedItemChanged: (int selectedItem) {
                    settingsStore.setFontFamily(_fontOptions[selectedItem]);
                  },
                  children: List.generate(_fontOptions.length, (int index) {
                    return Center(
                        child: Text(_fontOptions[index].isEmpty
                            ? '系统默认'
                            : _fontOptions[index]));
                  }),
                )),
          ),
        ),
      ),
    );
  }
}