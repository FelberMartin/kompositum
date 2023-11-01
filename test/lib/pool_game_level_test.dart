import 'dart:io';

import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/pool_game_level.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';
import '../test_util.dart';

void main() {
  late PoolGameLevel sut;

  setUp(() {
    sut = PoolGameLevel([Compounds.Krankenhaus]);
  });

  group("checkCompound", () {
    test(
        "should return true and remove the compound's components from list of shown components if it is correct",
        () {
      final result = sut.checkCompound("krank", "Haus");
      expect(result, isTrue);
      expect(sut.shownComponents, []);
    });

    test(
        "should not add the compound to the list of solved compounds if it is not correct",
        () {
      sut.checkCompound("krank", "Baum");
      expect(sut.shownComponents, containsAll(["krank", "Haus"]));
    });
  });

  group("isLevelFinished", () {
    test("should return true if all compounds are solved", () {
      sut.checkCompound("krank", "Haus");
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
}
