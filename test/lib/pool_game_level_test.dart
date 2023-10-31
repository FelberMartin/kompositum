import 'dart:io';

import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/pool_game_level.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';
import '../test_util.dart';

class MockPoolGenerator extends Mock implements CompoundPoolGenerator {}

void main() {
  late PoolGameLevel sut;
  late MockPoolGenerator poolGenerator;

  setUpAll(() {
    registerFallbackValue(CompactFrequencyClass.easy);
  });

  setUp(() async {
    poolGenerator = MockPoolGenerator();
    when(() => poolGenerator.generate(
      frequencyClass: any(named: "frequencyClass"),
      compoundCount: any(named: "compoundCount"),
    )).thenAnswer((_) async => [Compounds.Krankenhaus]);

    sut = PoolGameLevel(
      poolGenerator: poolGenerator,
      initialCompoundCount: 1,
    );
    await sut.init();
  });

  group("checkCompound", () {
      test(
        "should remove the compound's components from list of shown components if it is correct",
        () {
          sut.checkCompound("krank", "Haus");
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
      test(
        "should return true if all compounds are solved",
        () {
          sut.checkCompound("krank", "Haus");
          expect(sut.isLevelFinished(), isTrue);
      });

      test(
        "should return false if not all compounds are solved",
        () {
          expect(sut.isLevelFinished(), isFalse);
      });
  });

  group("getNextShownComponent", () {
      test(
        "should return the next component if there are more unshown components",
        () async {
          when(() => poolGenerator.generate(
            frequencyClass: any(named: "frequencyClass"),
            compoundCount: any(named: "compoundCount"),
          )).thenAnswer((_) async => [Compounds.Krankenhaus, Compounds.Apfelbaum]);
          sut = PoolGameLevel(
            poolGenerator: poolGenerator,
            initialCompoundCount: 2,
            maxShownComponentCount: 2,
          );
          await sut.init();

          final nextComponent = sut.getNextShownComponent();
          expect(nextComponent, isNotInList(sut.shownComponents));
      });

      test(
        "if there are are no compounds in the shown pool, the last getNextShownComponent adds a compound",
        () async {
          for (var i = 0; i < 5; i++) {   // Repeat to ensure that the test is not passing by luck
            when(() =>
                poolGenerator.generate(
                  frequencyClass: any(named: "frequencyClass"),
                  compoundCount: any(named: "compoundCount"),
                )).thenAnswer((_) async => Compounds.all);
            sut = PoolGameLevel(
              poolGenerator: poolGenerator,
              initialCompoundCount: 5,
              maxShownComponentCount: 2,
            );
            await sut.init();

            final allComponents = sut.shownComponents + sut.hiddenComponents;
            sut.shownComponents.clear();
            sut.shownComponents.add("krank");
            sut.hiddenComponents.clear();
            sut.hiddenComponents.addAll(allComponents.where((element) => element != "krank"));

            final nextComponent = sut.getNextShownComponent();
            expect(nextComponent, "Haus");
          }
        });
  });
}