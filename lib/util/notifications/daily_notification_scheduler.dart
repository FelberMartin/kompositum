import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/util/date_util.dart';

import 'notifictaion_manager.dart';

class DailyNotificationScheduler {

  static const notificationId = 0;
  static const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        '01',
        'WortschatzDailyNotification',
        channelDescription: 'Notifications for the daily levels in Wortschatz',
      )
    // iOS: IOSNotificationDetails(sound: '$sound.mp3'),
  );


  final NotificationManager notificationManager;
  final KeyValueStore keyValueStore;

  DailyNotificationScheduler(this.notificationManager, this.keyValueStore);

  void cancelDailyNotification() {
    notificationManager.cancel(notificationId);
  }

  Future<void> tryScheduleNextDailyNotification({required DateTime now}) async {
    cancelDailyNotification();
    final isEnabled = await keyValueStore.getBooleanSetting(BooleanSetting.dailyNotificationsEnabled);
    if (!isEnabled) {
      return;
    }
    return _scheduleNextDailyNotification(now);
  }

  Future<void> _scheduleNextDailyNotification(DateTime now) async {
    final nextNotificationDate = await _getNextNotificationDateTime(now);

    var title = "Tägliches Rätsel";
    if (Random().nextDouble() < 0.2) {
      if (Random().nextBool()) {
        title = "Wer rastet, der rostet";
      } else {
        title = "Täglich grüßt das Murmeltier";
      }
    }

    notificationManager.scheduleNotification(
      id: notificationId,
      title: title,
      description: "Dein tägliches Rätsel wartet noch darauf gelöst zu werden!",
      dateTime: nextNotificationDate,
      notificationDetails: notificationDetails,
    );
  }

  Future<DateTime> _getNextNotificationDateTime(DateTime now) async {
    var nextNotificationDate = now.copyWith(hour: 18);
    final isTodaysDailyCompleted = await _isTodaysDailyCompleted(now);
    final skipToNextDay = isTodaysDailyCompleted || nextNotificationDate.isBefore(now);
    if (skipToNextDay) {
      nextNotificationDate = nextNotificationDate.add(const Duration(days: 1));
    }

    return nextNotificationDate;
  }

  Future<bool> _isTodaysDailyCompleted(DateTime now) async {
    final completed = await keyValueStore.getDailiesCompleted();
    return completed.any((datetime) => datetime.isSameDate(now));
  }
}