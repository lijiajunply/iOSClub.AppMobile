

import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences{
  late SharedPreferences _prefs;

  AppSharedPreferences() {
    init();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

}