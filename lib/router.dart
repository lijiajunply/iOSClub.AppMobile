import 'package:get/get.dart';
import 'package:ios_club_app/pages/net_page.dart';
import 'package:ios_club_app/pages/electricity_page.dart';
import 'package:ios_club_app/pages/payment_page.dart';
import 'package:ios_club_app/pages/program_page.dart';

import 'pages/setting_page.dart';
import 'pages/home_page.dart';
import 'pages/link_page.dart';
import 'pages/member_page.dart';
import 'pages/profile_page.dart';
import 'pages/schedule_list_page.dart';
import 'pages/schedule_setting_page.dart';
import 'pages/school_bus_page.dart';
import 'pages/score_page.dart';

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
          name: '/About',
          page: () => const SettingPage(),
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
        GetPage(
          name: '/Net',
          page: () => const NetPage(),
        ),
      ];
}