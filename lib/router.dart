import 'package:get/get.dart';
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
  static List<GetPage> get getPages => [
        GetPage(
          name: '/',
          page: () => const HomePage(),
        ),
        GetPage(
          name: '/Schedule',
          page: () => const ScheduleListPage(),
        ),
        GetPage(
          name: '/Score',
          page: () => const ScorePage(),
        ),
        GetPage(
          name: '/Profile',
          page: () => const ProfilePage(),
        ),
        GetPage(
          name: '/Link',
          page: () => const LinkPage(),
        ),
        GetPage(
          name: '/Todo',
          page: () => const TodoPage(),
        ),
        GetPage(
          name: '/About',
          page: () => const AboutPage(),
        ),
        GetPage(
          name: '/ScheduleSetting',
          page: () => const ScheduleSettingPage(),
        ),
        GetPage(
          name: '/SchoolBus',
          page: () => const SchoolBusPage(),
        ),
        GetPage(
          name: '/iMember',
          page: () => const MemberPage(),
        ),
        GetPage(
          name: '/Program',
          page: () => const ProgramPage(),
        ),
        GetPage(
          name: '/Electricity',
          page: () => const ElectricityPage(),
        ),
        GetPage(
          name: '/Payment',
          page: () => PaymentPage(),
        ),
      ];
}
