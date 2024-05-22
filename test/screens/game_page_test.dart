import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/game/modi/classic/classic_level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/main_classic_game_page_state.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_compound_pool_generator.dart';
import '../mocks/mock_swappable_detector.dart';
import '../mocks/mock_tutorial_manager.dart';
import '../test_data/compounds.dart';
import '../test_util.dart';



void selectComponentByText(String text, GamePageState sut) {
  final component = sut.gameLevel.shownComponents.firstWhere((element) => element.text == text);
  sut.toggleSelection(component.id);
}

void main() {
  late MockCompoundPoolGenerator poolGenerator;
  final levelProvider = LogarithmicLevelSetupProvider();
  final keyValueStore = KeyValueStore();
  final swappableDetector = MockSwappableDetector();
  TutorialManager tutorialManager = MockTutorialManager();

  late GamePageState sut;

  Future<void> _pumpGamePage(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: myTheme,
      home: GamePage(
          state: MainClassicGamePageState(
              levelProvider: levelProvider,
              poolGenerator: poolGenerator,
              keyValueStore: keyValueStore,
              swappableDetector: swappableDetector,
              tutorialManager: tutorialManager)),
    ));
    await nonBlockingPump(tester);
    sut = tester.state(find.byType(GamePage));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    poolGenerator = MockCompoundPoolGenerator();
    registerFallbackValue(LevelSetup(
        levelIdentifier: "", compoundCount: 2, poolGenerationSeed: 1));
    when(() => poolGenerator.generateFromLevelSetup(any()))
        .thenAnswer((_) => Future.value([Compounds.Apfelbaum]));
  });

  group("Functionality tests", () {
    group("toggleSelection", () {
      testWidgets(
          "should select the toggled component as modifier, if nothing else is selected",
          (tester) async {
        await _pumpGamePage(tester);
        sut.gameLevel = ClassicGameLevel([Compounds.Apfelbaum]);
        final component = sut.gameLevel.shownComponents[0];
        sut.toggleSelection(component.id);

        expect(sut.selectedModifier, component);
      });

      testWidgets(
          "should selected the toggled component as head, if a modifier is already selected",
          (tester) async {
        await _pumpGamePage(tester);
        sut.gameLevel = ClassicGameLevel([Compounds.Apfelbaum]);
        final modifier = sut.gameLevel.shownComponents[0];
        sut.toggleSelection(modifier.id);
        final head = sut.gameLevel.shownComponents[1];
        sut.toggleSelection(head.id);

        expect(sut.selectedHead, head);
      });

      testWidgets(
          "should unselect the toggled component, if it is already selected",
          (tester) async {
        await _pumpGamePage(tester);
        sut.gameLevel = ClassicGameLevel([Compounds.Apfelbaum]);
        final modifier = sut.gameLevel.shownComponents[0];
        sut.toggleSelection(modifier.id);
        sut.toggleSelection(modifier.id);

        expect(sut.selectedModifier, isNull);
      });
    });

    testWidgets("should reset the selection after completing a compound",
        (tester) async {
      await _pumpGamePage(tester);
      sut.gameLevel =
          ClassicGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
      selectComponentByText("Apfel", sut);
      selectComponentByText("Baum", sut);

      await nonBlockingPump(tester);

      expect(sut.selectedModifier, null);
      expect(sut.selectedHead, null);
    });

    group("buyHint", () {
      testWidgets(
          "should set the selection to the new hint if the new hint is the modifier",
          (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 1000;
        sut.gameLevel =
            ClassicGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        selectComponentByText("Baum", sut);
        selectComponentByText("Schnee", sut);
        sut.buyHint();

        expect(
            sut.selectedModifier, sut.gameLevel.hints[0].hintedComponent);
        expect(sut.selectedHead, isNull);
      });

      testWidgets("should reset the selection if the new hint is the head",
          (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 1000;
        sut.gameLevel =
            ClassicGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        selectComponentByText("Baum", sut);
        selectComponentByText("Schnee", sut);
        sut.buyHint();
        sut.buyHint();

        expect(sut.selectedModifier, isNull);
        expect(sut.selectedHead, isNull);
      });

      testWidgets("should reset the attempts when buying a hint",
          (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 1000;
        sut.gameLevel = ClassicGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
        selectComponentByText("Baum", sut);
        selectComponentByText("Schnee", sut);
        expect(sut.gameLevel.attemptsWatcher.attemptsLeft, 4);
        sut.buyHint();

        expect(sut.gameLevel.hints.length, 1);
        expect(sut.gameLevel.attemptsWatcher.attemptsLeft, 5);
      });

      // This test fails when running all tests, but succeeds when running only this test
      testWidgets(skip: false, "should reduce the starCount by the normal cost",
          (tester) async {
        await _pumpGamePage(tester);
        sut.starCount = 100;
        final hintCost = sut.gameLevel.getHintCost();
        sut.buyHint();
        await nonBlockingPump(tester);

        expect(sut.starCount, 100 - hintCost);
      });
    });

    testWidgets("solving a compound should increase the star counter",
        (tester) async {
      await _pumpGamePage(tester);
      sut.gameLevel =
          ClassicGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
      final starCountBefore = sut.starCount;

      selectComponentByText("Apfel", sut);
      selectComponentByText("Baum", sut);

      await nonBlockingPump(tester);
      expect(sut.starCount, starCountBefore + Rewards.starsCompoundCompleted);
    });

    testWidgets("B08: When quickly clicking a component after solving a compound, the attempts should not be reduced",
            (tester) async {
          await _pumpGamePage(tester);
          sut.gameLevel =
              ClassicGameLevel([Compounds.Apfelbaum, Compounds.Schneemann]);
          selectComponentByText("Apfel", sut);
          selectComponentByText("Baum", sut);
          expect(sut.gameLevel.shownComponents.length, 2);
          expect(sut.gameLevel.attemptsWatcher.attemptsLeft, 5);

          selectComponentByText("Schnee", sut);
          expect(sut.selectedModifier?.text, "Schnee");
          await nonBlockingPump(tester);
          expect(sut.gameLevel.attemptsWatcher.attemptsLeft, 5);
        });
  });

  group("UI tests", () {
    testWidgets("After loading, the components are shown",
        (tester) async {
      await _pumpGamePage(tester);

      expect(find.text("Apfel").hitTestable(), findsOneWidget);
    });

    testWidgets("The clickindicator is shown at the beginning of the first level",
        (tester) async {
      when(() => poolGenerator.generateFromLevelSetup(any()))
          .thenAnswer((_) => Future.value([Compounds.Wortschatz]));
      tutorialManager = TutorialManager(keyValueStore);
      await _pumpGamePage(tester);

      final widgets = tester.widgetList(find.byKey(ValueKey("clickIndicator")));
      expect(widgets.any((widget) => widget is AnimatedOpacity && widget.opacity == 1.0), true);
    });

    testWidgets("The clickindicator is not shown for the second level",
            (tester) async {
          SharedPreferences.setMockInitialValues({"level": 2});
          tutorialManager = TutorialManager(keyValueStore);
          await _pumpGamePage(tester);

          final widgets = tester.widgetList(find.byKey(ValueKey("clickIndicator")));
          expect(widgets.any((widget) => widget is AnimatedOpacity && widget.opacity == 1.0), false);
        });
  });
}
