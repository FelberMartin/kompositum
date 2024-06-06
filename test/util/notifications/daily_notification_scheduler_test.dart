import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/util/extensions/date_util.dart';
import 'package:kompositum/util/feature_lock_manager.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../../mocks/mock_feature_lock_manager.dart';
import '../../mocks/mock_notification_manager.dart';

void main() {

  final MockNotificationManager notificationManager = MockNotificationManager();
  final MockFeatureLockManager featureLockManager = MockFeatureLockManager();
  late KeyValueStore keyValueStore;
  late DailyNotificationScheduler sut;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    keyValueStore = KeyValueStore();
    sut = DailyNotificationScheduler(
      notificationManager: notificationManager,
      keyValueStore: keyValueStore,
      featureLockManager: featureLockManager,
    );
  });

  test('should schedule notification', () async {
    final now = DateTime(2024, 04, 19);
    await sut.tryScheduleNextDailyNotification(now: now);
    expect(notificationManager.notifications, isNotEmpty);
    expect(notificationManager.notifications[0].dateTime.isSameDate(now), isTrue);
  });

  test('should schedule notification for the next day if it is already after 6pm', () async {
    final now = DateTime(2024, 04, 19, 20, 00);
    await sut.tryScheduleNextDailyNotification(now: now);
    expect(notificationManager.notifications, isNotEmpty);
    expect(notificationManager.notifications[0].dateTime.day, 20);
  });

  test('should schedule notification for the next day if the daily today is already completed', () async {
    final now = DateTime(2024, 04, 19);
    await keyValueStore.storeDailiesCompleted([now]);
    await sut.tryScheduleNextDailyNotification(now: now.copyWith(hour: 12));
    expect(notificationManager.notifications, isNotEmpty);
    expect(notificationManager.notifications[0].dateTime.day, 20);
  });

  test('should schedule no notification if setting disabled', () async {
    SharedPreferences.setMockInitialValues({"dailyNotificationsEnabled": false});
    await sut.tryScheduleNextDailyNotification(now: DateTime(2024, 04, 19));
    expect(notificationManager.notifications, isEmpty);
  });

  test('should schedule only one notification if update is called multiple times', () async {
    await sut.tryScheduleNextDailyNotification(now: DateTime(2024, 04, 19, 12));
    await sut.tryScheduleNextDailyNotification(now: DateTime(2024, 04, 19, 14));
    expect(notificationManager.notifications, hasLength(1));
  });

  test("should not schedule notification if the daily feature is still locked", () async {
    featureLockManager.setDailyLevelFeatureLocked(true);
    await sut.tryScheduleNextDailyNotification(now: DateTime(2024, 04, 19));
    expect(notificationManager.notifications, isEmpty);
  });


}