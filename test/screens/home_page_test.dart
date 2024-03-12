import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/screens/daily_overview_page.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_util.dart';

void main() {

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({"level": 3});
    await setupLocator(env: "test");
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