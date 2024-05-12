import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/screens/daily_overview_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/test_locator.dart';
import '../test_util.dart';

Future<void> completeAllDailiesInCurrentMonth() async {
  KeyValueStore keyValueStore = locator<KeyValueStore>();
  List<DateTime> completedDays = [];
  for (int i = 1; i <= 31; i++) {
    completedDays.add(DateTime(DateTime.now().year, DateTime.now().month, i));
  }
  await keyValueStore.storeDailiesCompleted(completedDays);
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await setupTestLocator();
  });

  testWidgets("With no dailies completed, do not show the monthly emoji", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: DailyOverviewPage()));
    await nonBlockingPump(tester);
    expect(find.byKey(Key("incomplete")), findsOneWidget);
    expect(find.byKey(ValueKey(DateTime.now().month)), findsNothing);
  });



  testWidgets("With all dailies in a month completed, do show the monthly emoji", (WidgetTester tester) async {
    await completeAllDailiesInCurrentMonth();
    await tester.pumpWidget(MaterialApp(theme: myTheme, home: DailyOverviewPage()));
    await nonBlockingPump(tester);
    expect(find.byKey(Key("incomplete")), findsNothing);
    expect(find.byKey(ValueKey(DateTime.now().month)), findsOneWidget);
  });


}