import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ios_club_app/system_services/android/notification_service.dart';
import 'package:ios_club_app/system_services/ios/notification_service.dart';

import '../models/course_model.dart';

class UniversalNotificationService {
  static Future<void> set(BuildContext context) async {
    if (Platform.isAndroid) {
      await NotificationService.set(context);
    } else if (Platform.isIOS) {
      await IOSNotificationService.set(context);
    }
  }

  static Future<void> remind() async {
    if (Platform.isAndroid) {
      await NotificationService.remind();
    } else if (Platform.isIOS) {
      await IOSNotificationService.remind();
    }
  }

  static Future<void> toList(List<CourseModel> courses) async {
    if (Platform.isAndroid) {
      await NotificationService.toList(courses);
    } else if (Platform.isIOS) {
      await IOSNotificationService.toList(courses);
    }
  }
}