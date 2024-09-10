import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/util/extensions/date_util.dart';
import 'package:kompositum/util/feature_lock_manager.dart';

import 'notifictaion_manager.dart';

class DailyNotificationScheduler {

  static const notificationCount = 7;
  static const notificationIdOffset = 1000;

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
  final FeatureLockManager featureLockManager;

  DailyNotificationScheduler({
    required this.notificationManager,
    required this.keyValueStore,
    required this.featureLockManager,
  });

  Future<void> cancelDailyNotifications() async {
    for (var i = 0; i < notificationCount; i++) {
      await notificationManager.cancel(notificationIdOffset + i);
    }
  }

  Future<void> tryScheduleNextDailyNotifications({required DateTime now}) async {
    await cancelDailyNotifications();
    final isEnabled = await keyValueStore.getBooleanSetting(BooleanSetting.dailyNotificationsEnabled);

    if (!isEnabled || featureLockManager.isDailyLevelFeatureLocked) {
      return;
    }
    return _scheduleNextDailyNotifications(now);
  }

  Future<void> _scheduleNextDailyNotifications(DateTime now) async {
    final nextNotificationDate = await _getNextNotificationDateTime(now);

    for (var i = 0; i < notificationCount; i++) {
      await _scheduleDailyNotification(
        notificationId: notificationIdOffset + i,
        notificationDate: nextNotificationDate.add(Duration(days: i)),
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int notificationId,
    required DateTime notificationDate
  }) {
    var title = Flavor.instance.uiString.ttlDefaultNotificationTitle;
    // With a chance of 20%, choose one of the variant titles
    if (Random().nextDouble() < 0.2) {
      final index = Random().nextInt(Flavor.instance.uiString.ttlNotificationVariants.length);
      title = Flavor.instance.uiString.ttlNotificationVariants[index];
    }

    return notificationManager.scheduleNotification(
      id: notificationId,
      title: title,
      description: Flavor.instance.uiString.lblNotificationDescription,
      dateTime: notificationDate,
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