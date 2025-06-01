import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/Models/LinkModel.dart';
import 'package:ios_club_app/PageModels/CourseColorManager.dart';

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
      IconData(
        re['unicode_decimal'],
        fontFamily: 'IconFont',
        matchTextDirection: false,
      ),
      size: 35,
      color: CourseColorManager.generateSoftColor(model, isDark: true),
    );
  }
}
