import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/locator.dart';
import 'package:kompositum/widgets/game_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test_data/compounds.dart';

class MockPoolGenerator extends Mock implements CompoundPoolGenerator {
  @override
  List<Compound> getBlockedCompounds() {
    return [];
  }

  @override
  Future<void> setBlockedCompounds(List<String> blockedCompoundNames) {
    return Future.value();
  }
}

class MockSwappableDetector extends Mock implements SwappableDetector {
  @override
  Future<List<Swappable>> getSwappables(List<Compound> compounds) {
    return Future.value([]);
  }
}

void main() {
  late MockPoolGenerator poolGenerator;
  final levelProvider = BasicLevelProvider();
  final keyValueStore = KeyValueStore();
  final swappableDetector = MockSwappableDetector();

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;

    setupLocator(env: "test");
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    poolGenerator = MockPoolGenerator();
    registerFallbackValue(LevelSetup(compoundCount: 2, poolGenerationSeed: 1));
    when(() => poolGenerator.generateFromLevelSetup(any()))
        .thenAnswer((_) => Future.value([Compounds.Apfelbaum]));
  });

  testWidgets(skip: false, "After loading, the components are shown", (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: GamePage(title: "title", levelProvider: levelProvider, poolGenerator: poolGenerator, keyValueStore: keyValueStore, swappableDetector: swappableDetector)
    ));
    await tester.pumpAndSettle();

    expect(find.text("Apfel"), findsOneWidget);
  });

  // Test passes even if components are not shown in the app :(
  testWidgets(skip: true, "After finished the first level and waiting for loading, the seconds level's components are shown", (tester) async {
    final homePage = GamePage(title: "title", levelProvider: levelProvider, poolGenerator: poolGenerator, keyValueStore: keyValueStore, swappableDetector: swappableDetector);
    await tester.pumpWidget(MaterialApp(home: homePage));
    await tester.pumpAndSettle();

    expect(find.text("Apfel"), findsOneWidget);

    when(() => poolGenerator.generateFromLevelSetup(any()))
        .thenAnswer((_) => Future.value([Compounds.Schneemann]));
    final GamePageState state = tester.state(find.byType(GamePage));
    state.toggleSelection(0);
    state.toggleSelection(1);
    await tester.pump(Duration(milliseconds: 1));
    expect(find.text("Apfel"), findsNothing);

    // await tester.pumpAndSettle();
    expect(find.text("Schnee"), findsOneWidget);
  });
}