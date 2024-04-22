import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockNotification {
  final int id;
  final String title;
  final String description;
  final DateTime dateTime;

  MockNotification(this.id, this.title, this.description, this.dateTime);
}

class MockNotificationManager extends Mock implements NotificationManager {

  final notifications = <MockNotification>[];

  @override
  void scheduleNotification({required int id, required String title, required String description, required DateTime dateTime, required NotificationDetails notificationDetails, String payload = ""}) {
    notifications.add(MockNotification(id, title, description, dateTime));
  }

  @override
  cancel(id) {
    notifications.removeWhere((n) => n.id == id);
  }

  @override
  cancelAll() {
    notifications.clear();
  }
}