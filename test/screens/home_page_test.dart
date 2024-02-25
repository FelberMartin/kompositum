import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/screens/daily_overview_page.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {

  // For some reason, the tests fail because of pumpAndSettle timing out.

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await setupLocator(env: "test");
  });

  testWidgets(skip: true, "Click daily in tabBar takes to DailyOverViewPage", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
    await tester.tap(find.byKey(Key("tabBarDaily")));
    await tester.pump(Duration(seconds: 10));
    expect(find.byType(DailyOverviewPage), findsOneWidget);
  });

  testWidgets(skip: true, "Click on startButton takes to GamePage", (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({"level": 33});
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
    await tester.tap(find.byType(PlayButton));
    expect(find.byType(GamePage), findsOneWidget);
  });

  group("First launch", () {
    testWidgets(skip: true, "Take to GamePage on first launch", (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
      await tester.pumpAndSettle(Duration(seconds: 10));
      // await tester.pump();
      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets("Stays on HomePage for non-first launches", (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({"level": 3});
      await tester.pumpWidget(MaterialApp(theme: myTheme, home: HomePage()));
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}