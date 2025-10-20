import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/models/link_model.dart';
import 'package:ios_club_app/pageModels/course_color_manager.dart';

class IconUtil {
  static Future<Widget> getIconFont(LinkModel model) async {
    if (model.icon == null || model.icon!.isEmpty) {
      return Image.network(
        'https://${model.url.replaceAll("https://", "").replaceAll("http://", "").split('/').first}/favicon.ico',
        width: 40,
        height: 40,
      );
    }

    if (model.icon!.startsWith('http')) {
      return Image.network(
        model.icon!,
        width: 40,
        height: 40,
      );
    }
    final dateList =
        await rootBundle.loadString('assets/iconfont/iconfont.json');
    var iconMap = jsonDecode(dateList);
    var a = iconMap['glyphs'] as List<dynamic>;
    var re = a.firstWhere((element) => element['font_class'] == model.icon);
    return Icon(
      createIconData(re['unicode_decimal']), // 使用静态方法创建 IconData
      size: 35,
      color: CourseColorManager.generateSoftColor(model, isDark: true),
    );
  }
  
  // 添加一个静态方法来创建 IconData 实例，以解决 tree shaking 问题
  static IconData createIconData(int codePoint) {
    return IconData(
      codePoint,
      fontFamily: 'IconFont',
      matchTextDirection: false,
    );
  }
}