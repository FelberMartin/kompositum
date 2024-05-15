import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/game/pool_game_level.dart';
import 'package:kompositum/main.dart';
import 'package:kompositum/screens/daily_overview_page.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/screens/game_page_daily.dart';
import 'package:kompositum/screens/home_page.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/test_locator.dart';
import '../mocks/mock_notification_manager.dart';
import '../test_util.dart';

void main() {

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({"level": 3});
    await setupTestLocator();
  });

  testWidgets("The homePage stops loading", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
    await tester.pumpAndSettle();
    // Expect the PlayButton to show "Level 3"
    expect(find.text("Level 3"), findsAtLeastNWidgets(1));
  });

  group("DailyNotifications", () {
    // TODO: these tests currently only work when run before 18:00. Fix this by mocking the DateTime

    testWidgets("when opening the app an todays daily is not finished, create a notification", (WidgetTester tester) async {
      initNotifications();
      await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
      await nonBlockingPump(tester);
      final MockNotificationManager notificationManager = locator<NotificationManager>() as MockNotificationManager;
      expect(notificationManager.notifications, isNotEmpty);
      expect(notificationManager.notifications[0].id, DailyNotificationScheduler.notificationId);
      final delta = notificationManager.notifications[0].dateTime.difference(DateTime.now());
      expect(delta.inHours, lessThanOrEqualTo(24));
    });

    testWidgets("after finishing the daily level, the notification is created for the next day", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
      await nonBlockingPump(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("daily_play_button")).hitTestable());
      await nonBlockingPump(tester);
      final GamePageDailyState state = tester.state(find.byType(GamePage)) as GamePageDailyState;
      state.poolGameLevel = PoolGameLevel([]);
      state.levelCompleted();
      await nonBlockingPump(tester);

      final MockNotificationManager notificationManager = locator<NotificationManager>() as MockNotificationManager;
      expect(notificationManager.notifications, isNotEmpty);
      expect(notificationManager.notifications[0].id, DailyNotificationScheduler.notificationId);
      expect(notificationManager.notifications[0].dateTime.day, isNot(DateTime.now().day));
    });
  });

  testWidgets("Click daily in tabBar takes to DailyOverViewPage", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
    await nonBlockingPump(tester);
    await tester.tap(find.byKey(Key("tabBarDaily")));
    await nonBlockingPump(tester);
    expect(find.byType(DailyOverviewPage), findsOneWidget);
  });

  testWidgets("Click on startButton takes to GamePage", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
    await nonBlockingPump(tester);
    await tester.tap(find.byType(PlayButton).hitTestable());
    await nonBlockingPump(tester);
    expect(find.byType(GamePage), findsOneWidget);
  });

  group("First launch", () {
    testWidgets("Take to GamePage on first launch", (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
      await nonBlockingPump(tester);
      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets("Stays on HomePage for non-first launches", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}