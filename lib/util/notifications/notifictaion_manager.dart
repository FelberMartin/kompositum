import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationManager() {
    _initializeNotification();
  }

  /// Initialize notification
  void _initializeNotification() async {
    _configureLocalTimeZone();
    const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

    const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings("outline");

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String description,
    required DateTime dateTime,
    required NotificationDetails notificationDetails,
    String payload = ""
  }) {
    return flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      description,
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
          .absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  cancelAll() async => await flutterLocalNotificationsPlugin.cancelAll();

  cancel(id) async => await flutterLocalNotificationsPlugin.cancel(id);
}