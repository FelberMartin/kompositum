import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/attempts_watcher.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/pool_game_level.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/screens/game_page_classic.dart';
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
    registerFallbackValue(LevelSetup(levelIdentifier: "", compoundCount: 2, poolGenerationSeed: 1));
    when(() => poolGenerator.generateFromLevelSetup(any()))
        .thenAnswer((_) => Future.value([Compounds.Apfelbaum]));
  });


  group("Functionality tests", () {
    late GamePageState sut;

    Future<void> _pumpGamePage(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: myTheme,
        home: GamePage(state: GamePageClassicState(
            levelProvider: levelProvider, poolGenerator: poolGenerator,
            keyValueStore: keyValueStore, swappableDetector: swappableDetector
        )),
      ));
      await tester.pumpAndSettle();
      sut = tester.state(find.byType(GamePage));
    }

    group("toggleSelection", () {
      testWidgets("should select the toggled component as modifier, if nothing else is selected", (tester) async {
        await _pumpGamePage(tester);
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum]);
        final component = sut.poolGameLevel.shownComponents[0];
        sut.toggleSelection(component.id);

        expect(sut.selectedModifier, component);
      });

      testWidgets("should selected the toggled component as head, if a modifier is already selected", (tester) async {
        await _pumpGamePage(tester);
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum]);
        final modifier = sut.poolGameLevel.shownComponents[0];
        sut.toggleSelection(modifier.id);
        final head = sut.poolGameLevel.shownComponents[1];
        sut.toggleSelection(head.id);

        expect(sut.selectedHead, head);
      });

      testWidgets("should unselect the toggled component, if it is already selected", (tester) async {
        await _pumpGamePage(tester);
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum]);
        final modifier = sut.poolGameLevel.shownComponents[0];
        sut.toggleSelection(modifier.id);
        sut.toggleSelection(modifier.id);

        expect(sut.selectedModifier, isNull);
      });
    });

    testWidgets("should reset the selection after completing a compound", (tester) async {
      await _pumpGamePage(tester);
      sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
      sut.toggleSelection(0);   // Apfel
      sut.toggleSelection(1);   // Baum

      await tester.pumpAndSettle(Duration(seconds: 2));

      expect(sut.selectedModifier, null);
      expect(sut.selectedHead, null);
    });

    group("attemptsCounter", () {
      testWidgets("should reduce the attemptsCounter on a false compound entered", (tester) async {
        await _pumpGamePage(tester);
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        sut.toggleSelection(0);   // Apfel
        sut.toggleSelection(2);   // Schnee

        expect(sut.attemptsWatcher.attemptsLeft, sut.attemptsWatcher.maxAttempts - 1);
      });

      testWidgets("should reset the attemptsCounter after completing a compound", (tester) async {
        await _pumpGamePage(tester);
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        sut.toggleSelection(0);   // Apfel
        sut.toggleSelection(1);   // Baum

        await tester.pumpAndSettle(Duration(seconds: 2));

        expect(sut.attemptsWatcher.attemptsLeft, sut.attemptsWatcher.maxAttempts);
      });

      testWidgets(skip: true, "should show the NoAttemptsLeftDialog if no attempts are left", (tester) async {
        await _pumpGamePage(tester);
        sut.attemptsWatcher = AttemptsWatcher(maxAttempts: 1);
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        sut.toggleSelection(0);   // Apfel
        sut.toggleSelection(2);   // Schnee

        await tester.pumpAndSettle(Duration(seconds: 2));

        expect(find.text("Du hast alle Versuche aufgebraucht!"), findsOneWidget);
      });
    });

    group("buyHint", () {
      testWidgets("should set the selection to the new hint if the new hint is the modifier", (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 1000;
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        sut.toggleSelection(1);   // Baum
        sut.toggleSelection(2);   // Schnee
        sut.buyHint();

        expect(sut.selectedModifier, sut.poolGameLevel.hints[0].hintedComponent);
        expect(sut.selectedHead, isNull);
      });

      testWidgets("should reset the selection if the new hint is the head", (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 1000;
        sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        sut.toggleSelection(1);   // Baum
        sut.toggleSelection(2);   // Schnee
        sut.buyHint();
        sut.buyHint();

        expect(sut.selectedModifier, isNull);
        expect(sut.selectedHead, isNull);
      });

      testWidgets("should reduce the starCount by the normal cost", (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 100;
        sut.buyHint();
        final hintCost = sut.getHintCost();
        expect(sut.starCount, 100 - hintCost);
      });
    });

    group("getHintCost", () {
      testWidgets("should be the base with no used attempts", (tester) async {
        await _pumpGamePage(tester);
        expect(sut.getHintCost(), Costs.hintCostBase);
      });

      testWidgets("should be the base plus the increase per failed attempt", (tester) async {
        await _pumpGamePage(tester);
        sut.attemptsWatcher.attemptUsed();
        expect(sut.getHintCost(), Costs.hintCostBase + Costs.hintCostIncreasePerFailedAttempt);
      });
    });

    testWidgets("solving a compound should increase the star counter", (tester) async {
      await _pumpGamePage(tester);
      sut.poolGameLevel = PoolGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
      final starCountBefore = sut.starCount;

      sut.toggleSelection(0);   // Apfel
      sut.toggleSelection(1);   // Baum

      await tester.pumpAndSettle(Duration(milliseconds: 2000));
      expect(sut.starCount, starCountBefore + Rewards.starsCompoundCompleted);
    });

  });


  group("UI tests", () {
    testWidgets(skip: false, "After loading, the components are shown", (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: myTheme,
          home: GamePage(state: GamePageClassicState(levelProvider: levelProvider, poolGenerator: poolGenerator, keyValueStore: keyValueStore, swappableDetector: swappableDetector))
      ));
      await tester.pumpAndSettle();

      expect(find.text("Apfel"), findsNWidgets(2));  // Due to the 3d container there are two widgets with the same text
    });
  });

}