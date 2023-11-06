import 'dart:io';

import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/pool_game_level.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';
import '../test_util.dart';

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
  });

  group("removeCompoundFromShown", () {
    test(
        "should remove the compound from the shown components",
        () {
      sut.removeCompoundFromShown(Compounds.Krankenhaus);
      expect(sut.shownComponents, isEmpty);
    });

    test(
        "should fill the shown components with new components",
        () {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 2);
      sut.removeCompoundFromShown(Compounds.Krankenhaus);
      expect(sut.shownComponents, isNotEmpty);
    });
  });

  group("isLevelFinished", () {
    test("should return true if all compounds are solved", () {
      sut.removeCompoundFromShown(Compounds.Krankenhaus);
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
        sut.shownComponents.clear();
        sut.shownComponents.add("krank");
        sut.hiddenComponents.clear();
        sut.hiddenComponents
            .addAll(allComponents.where((element) => element != "krank"));

        for (var i = 0; i < 5; i++) {
          // Repeat to ensure that the test is not passing by luck
        final nextComponent = sut.getNextShownComponent();
        expect(nextComponent, "Haus");
      }
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
      expect(sut.hints.first.hintedComponent, equals("krank"));
      expect(sut.hints.first.type, equals(HintComponentType.modifier));

      sut.removeCompoundFromShown(Compounds.Krankenhaus);
      expect(sut.hints, isEmpty);
    });

    test("should not remove the hint if the hinted component is not solved", () {
      sut = PoolGameLevel([Compounds.Krankenhaus, Compounds.Apfelbaum], maxShownComponentCount: 4);
      sut.hints.add(Hint("krank", HintComponentType.modifier));

      sut.removeCompoundFromShown(Compounds.Apfelbaum);
      expect(sut.hints, hasLength(1));
    });
  });
}
