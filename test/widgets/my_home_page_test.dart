import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/locator.dart';
import 'package:kompositum/widgets/home_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_data/compounds.dart';

class MockPoolGenerator extends Mock implements CompoundPoolGenerator {}

void main() {
  late MockPoolGenerator poolGenerator;
  final levelProvider = BasicLevelProvider();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    poolGenerator = MockPoolGenerator();
    registerFallbackValue(LevelSetup(compoundCount: 2, poolGenerationSeed: 1));
    when(() => poolGenerator.generateFromLevelSetup(any()))
        .thenAnswer((_) => Future.value([Compounds.Apfelbaum]));
  });

  testWidgets("After loading, the components are shown", (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: MyHomePage(title: "title", levelProvider: levelProvider, poolGenerator: poolGenerator)
    ));
    await tester.pumpAndSettle();

    expect(find.text("Apfel"), findsOneWidget);
  });

  // Test passes even if components are not shown in the app :(
  testWidgets(skip: true, "After finished the first level and waiting for loading, the seconds level's components are shown", (tester) async {
    final homePage = MyHomePage(title: "title", levelProvider: levelProvider, poolGenerator: poolGenerator);
    await tester.pumpWidget(MaterialApp(home: homePage));
    await tester.pumpAndSettle();

    expect(find.text("Apfel"), findsOneWidget);

    when(() => poolGenerator.generateFromLevelSetup(any()))
        .thenAnswer((_) => Future.value([Compounds.Schneemann]));
    final MyHomePageState state = tester.state(find.byType(MyHomePage));
    state.toggleSelection(0);
    state.toggleSelection(1);
    await tester.pump(Duration(milliseconds: 1));
    expect(find.text("Apfel"), findsNothing);

    // await tester.pumpAndSettle();
    expect(find.text("Schnee"), findsOneWidget);
  });
}