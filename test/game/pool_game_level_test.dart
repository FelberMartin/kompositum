import 'dart:io';
import 'dart:math';

import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/pool_game_level.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';
import '../test_util.dart';


void removeCompoundHelper(PoolGameLevel sut, Compound compound) {
  final modifier = sut.shownComponents.firstWhere((element) => element.text == compound.modifier);
  final head = sut.shownComponents.firstWhere((element) => element.text == compound.head);
  sut.removeCompoundFromShown(compound, modifier, head);
}

void main() {
  late PoolGameLevel sut;

  setUp(() {
    sut = PoolGameLevel([Compounds.Krankenhaus]);
  });

  group("getCompoundIfExisting", () {
    test(
        "should return true if the compound exists",
        () {
      final result = sut.getCompoundIfExisting("krank", "Haus");
      expect(result, isNotNull);
      expect(result, Compounds.Krankenhaus);
    });

    test(
        "should return false if the compound does not exist",
        () {
      final result = sut.getCompoundIfExisting("krank", "Baum");
      expect(result, isNull);
    });

    test("should return the swapped compound if it exists", () {
      sut = PoolGameLevel([Compounds.Maschinenbau], swappableCompounds: [Swappable(Compounds.Maschinenbau, Compounds.Baumaschine)]);
      final result = sut.getCompoundIfExisting("Bau", "Maschine");
      expect(result, isNotNull);
      expect(result, Compounds.Baumaschine);
    });

    test("should return the compound and not the swapped version if entered non-swapped", () {
      sut = PoolGameLevel([Compounds.Maschinenbau], swappableCompounds: [Swappable(Compounds.Maschinenbau, Compounds.Baumaschine)]);
      final result = sut.getCompoundIfExisting("Maschine", "Bau");
      expect(result, isNotNull);
      expect(result, Compounds.Maschinenbau);
    });
  });

  group("removeCompoundFromShown", () {
    test(
        "should remove the compound from the shown components",
        () {
      removeCompoundHelper(sut, Compounds.Krankenhaus);
      expect(sut.shownComponents, isEmpty);
    });

    test(
        "should fill the shown components with new components",
        () {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 2);
      sut.shownComponents.clear();
      sut.shownComponents.addAll(UniqueComponent.fromCompounds([Compounds.Krankenhaus]));
      sut.hiddenComponents.clear();
      sut.hiddenComponents.addAll(UniqueComponent.fromCompounds([Compounds.Apfelbaum]));

      removeCompoundHelper(sut, Compounds.Krankenhaus);
      expect(sut.shownComponents, isNotEmpty);
    });

    test("should remove the original of the swapped compound if it exists", () {
      sut = PoolGameLevel([Compounds.Maschinenbau], swappableCompounds: [Swappable(Compounds.Maschinenbau, Compounds.Baumaschine)]);
      removeCompoundHelper(sut, Compounds.Baumaschine);
      expect(sut.shownComponents, isEmpty);
    });
  });

  group("isLevelFinished", () {
    test("should return true if all compounds are solved", () {
      removeCompoundHelper(sut, Compounds.Krankenhaus);
      expect(sut.isLevelFinished(), isTrue);
    });

    test("should return false if not all compounds are solved", () {
      expect(sut.isLevelFinished(), isFalse);
    });
  });

  group("getNextShownComponent", () {
    test(
        "should return the next component if there are more unshown components",
        () async {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 2);

      final nextComponent = sut.getNextShownComponent();
      expect(nextComponent, isNotInList(sut.shownComponents));
    });

    test(
        "if there are are no compounds in the shown pool, the last getNextShownComponent adds a compound",
        () async {
        sut = PoolGameLevel(
          Compounds.all,
          maxShownComponentCount: 2,
        );

        final allComponents = sut.shownComponents + sut.hiddenComponents;
        final krankComponent = allComponents.firstWhere((element) => element.text == "krank");
        sut.shownComponents.clear();
        sut.shownComponents.add(krankComponent);
        sut.hiddenComponents.clear();
        sut.hiddenComponents
            .addAll(allComponents.where((element) => element != krankComponent));

        for (var i = 0; i < 5; i++) {
          // Repeat to ensure that the test is not passing by luck
          final nextComponent = sut.getNextShownComponent();
          expect(nextComponent.text, "Haus");
        }
    });

    test("should return the same component for the same passed seed", () {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 2);
      final firstComponent = sut.getNextShownComponent(seed: 1);
      final secondComponent = sut.getNextShownComponent(seed: 1);
      expect(firstComponent, equals(secondComponent));
    });

    test("should return different components if no seed is passed", () {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 2);
      final components = <UniqueComponent>[];
      for (var i = 0; i < 10; i++) {
        components.add(sut.getNextShownComponent());
      }
      expect(components.toSet().length, 2);
    });
  });

  group("Hints", () {
    test("should add a hint when getHint is called", () {
      sut.requestHint();
      expect(sut.hints, hasLength(1));
    });

    test("should not add a hint when getHint is called and there are already two hints", () {
      sut.requestHint();
      sut.requestHint();
      sut.requestHint();
      expect(sut.hints, hasLength(2));
    });

    test("should remove the hint if the hinted component is solved", () {
      sut = PoolGameLevel([Compounds.Krankenhaus], maxShownComponentCount: 2);
      sut.requestHint();
      expect(sut.hints, hasLength(1));
      expect(sut.hints.first.hintedComponent.text, "krank");
      expect(sut.hints.first.type, equals(HintComponentType.modifier));

      removeCompoundHelper(sut, Compounds.Krankenhaus);
      expect(sut.hints, isEmpty);
    });

    test("should not remove the hint if the hinted component is not solved", () {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 4);
      sut.hints.add(Hint(UniqueComponent("krank", 123), HintComponentType.modifier));

      removeCompoundHelper(sut, Compounds.Apfelbaum);
      expect(sut.hints, hasLength(1));
    });
  });
}
