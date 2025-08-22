import 'package:flutter/cupertino.dart';
import 'package:ios_club_app/pages/electricity_page.dart';
import 'package:ios_club_app/pages/payment_page.dart';
import 'package:ios_club_app/pages/program_page.dart';

import 'Pages/about_page.dart';
import 'Pages/home_page.dart';
import 'Pages/link_page.dart';
import 'Pages/member_page.dart';
import 'Pages/profile_page.dart';
import 'Pages/schedule_list_page.dart';
import 'Pages/schedule_setting_page.dart';
import 'Pages/school_bus_page.dart';
import 'Pages/score_page.dart';
import 'Pages/todo_page.dart';

class AppRouter {
  static Map<String, Widget Function(BuildContext)> get routes => {
        '/': (context) => const HomePage(),
        '/Schedule': (context) => const ScheduleListPage(),
        '/Score': (context) => const ScorePage(),
        '/Profile': (context) => const ProfilePage(),
        '/Link': (context) => const LinkPage(),
        '/Todo': (context) => const TodoPage(),
        '/About': (context) => const AboutPage(),
        '/ScheduleSetting': (context) => const ScheduleSettingPage(),
        '/SchoolBus': (context) => const SchoolBusPage(),
        '/iMember': (context) => const MemberPage(),
        '/Program': (context) => const ProgramPage(),
        '/Electricity': (context) => const ElectricityPage(),
        '/Payment': (context) => const PaymentPage(),
      };
}
