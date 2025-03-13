import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class IconUtil {
  static Future<Widget> getIconFont(String iconName) async {
    if (iconName.startsWith('http')) {
      return Image.network(iconName,width: 40,height: 40,);
    }
    final dateList = await rootBundle.loadString('assets/iconfont/iconfont.json');
    var iconMap = jsonDecode(dateList);
    var a = iconMap['glyphs'] as List<dynamic>;
    var re = a.firstWhere((element) => element['font_class'] == iconName);
    return Icon(IconData(re['unicode_decimal'], fontFamily: 'IconFont'),
        size: 35);
  }
}
