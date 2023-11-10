import 'package:flutter/widgets.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/game/compact_frequency_class.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';
import 'database_initializer_test.dart';

void main() {
  late DatabaseInterface sut;
  late DatabaseInitializer databaseInitializer;
  late MockCompoundOrigin compoundOrigin;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    compoundOrigin = MockCompoundOrigin();
    databaseInitializer = DatabaseInitializer(compoundOrigin,
        useInMemoryDatabase: true, reset: true);
    sut = DatabaseInterface(databaseInitializer);
  });

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group("getCompoundCount", () {
    test(
      "should return the number of compounds",
      () async {
        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => Compounds.all);
        final count = await sut.getCompoundCount();
        expect(count, Compounds.all.length);
      },
    );
  });

  group("getAllCompounds", () {
    test(
      "should return all compounds",
      () async {
        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => Compounds.all);
        final compounds = await sut.getAllCompounds();
        expect(compounds, Compounds.all);
      },
    );
  });

  group("getCompound", () {
    setUp(() =>
    {
      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => [Compounds.Apfelbaum])
    });

    test(
      "should return the compound with the given modifier and head",
          () async {
        final compound = await sut.getCompound("Apfel", "Baum");
        expect(compound, Compounds.Apfelbaum);
      },
    );

    test(
      "should return null if no compound with the given modifier and head exists",
          () async {
        final compound = await sut.getCompound("Sand", "Burg");
        expect(compound, isNull);
      },
    );

    test(
      "should return null if the modifier is empty",
          () async {
        final compound = await sut.getCompound("", "Baum");
        expect(compound, isNull);
      },
    );
  });

  group("getCompoundCaseInsensitive", () {
    setUp(() => {
          when(() => compoundOrigin.getCompounds())
              .thenAnswer((_) async => [Compounds.Apfelbaum])
        });

    test(
      "should return the compound with the given modifier and head",
      () async {
        final compound = await sut.getCompoundCaseInsensitive("Apfel", "Baum");
        expect(compound, Compounds.Apfelbaum);
      },
    );

    test(
      "should return null if no compound with the given modifier and head exists",
      () async {
        final compound = await sut.getCompoundCaseInsensitive("Sand", "Burg");
        expect(compound, isNull);
      },
    );

    test(
      "should return null if the modifier is empty",
      () async {
        final compound = await sut.getCompoundCaseInsensitive("", "Baum");
        expect(compound, isNull);
      },
    );

    test(
      "should not be case sensitive",
      () async {
        final compound = await sut.getCompoundCaseInsensitive("apfel", "baum");
        expect(compound, Compounds.Apfelbaum);
      },
    );

    test("edgecase: Frühschoppen, should not crash", () async {
      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => [Compounds.Fruehschoppen]);
      final compound = await sut.getCompoundCaseInsensitive("früh", "Schoppen");
      expect(compound, Compounds.Fruehschoppen);
    });

    test("edgecase: Überdachung, should not crash", () async {
      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => [Compounds.Ueberdachung]);
      final compound = await sut.getCompoundCaseInsensitive("Über", "Dach");
      expect(compound, Compounds.Ueberdachung);
    });
  });

  group("getRandomCompoundRestricted", () {
    test("should return null if no compound with the given restrictions exists",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Krankenhaus.withFrequencyClass(1)]);
      final compound =
          await sut.getRandomCompoundRestricted(maxFrequencyClass: 0);
      expect(compound, isNull);
    });

    test(
        "should return a compound with a frequency class lower or equal to the given frequency class",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Krankenhaus.withFrequencyClass(1)]);
      final compound =
          await sut.getRandomCompoundRestricted(maxFrequencyClass: 1);
      expect(compound, Compounds.Krankenhaus);
    });

    test(
      "should return a compound if frequency class if null",
      () async {
        when(() => compoundOrigin.getCompounds()).thenAnswer(
            (_) async => [Compounds.Krankenhaus.withFrequencyClass(1)]);
        final compound =
            await sut.getRandomCompoundRestricted(maxFrequencyClass: null);
        expect(compound, Compounds.Krankenhaus);
      },
    );

    test("should return a compound fitting the restrictedComponents", () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Krankenhaus, Compounds.Spielplatz]);
      final compound = await sut.getRandomCompoundRestricted(
          maxFrequencyClass: null, forbiddenComponents: ["krank"]);
      expect(compound, Compounds.Spielplatz);
    });

    test(
        "should return null if no compound fitting the restrictedComponents exists",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Krankenhaus, Compounds.Spielplatz]);
      final compound = await sut.getRandomCompoundRestricted(
          maxFrequencyClass: null, forbiddenComponents: ["Haus", "Spiel"]);
      expect(compound, isNull);
    });

    test(
        "should return null if no compound fitting the restrictedComponents exists, ignoring case",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Krankenhaus, Compounds.Spielplatz]);
      final compound = await sut.getRandomCompoundRestricted(
          maxFrequencyClass: null, forbiddenComponents: ["haus", "spiel"]);
      expect(compound, isNull);
    });

    test(
        "should return null independent of multiple compounds violating a single forbiddenCompound",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Apfelkuchen, Compounds.Kuchenform]);
      final compound = await sut.getRandomCompoundRestricted(
          maxFrequencyClass: null, forbiddenComponents: ["Kuchen"]);
      expect(compound, isNull);
    });

    test(
        "if there are multiple compounds fitting the restrictions, both should be returned eventually",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Apfelkuchen, Compounds.Kuchenform]);
      final returnedCompounds = [];
      for (var i = 0; i < 20; i++) {
        // this test will fail once in 2^20 / 2 times ~ 1 in 0.5 million times
        final compound =
            await sut.getRandomCompoundRestricted(maxFrequencyClass: null);
        returnedCompounds.add(compound);
      }
      expect(returnedCompounds,
          containsAll([Compounds.Apfelkuchen, Compounds.Kuchenform]));
    });
  });

  group("getRandomCompounds", () {
    test("should return the given number of compounds", () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Apfelkuchen, Compounds.Kuchenform]);
      final compounds =
          await sut.getRandomCompounds(count: 2, maxFrequencyClass: null);
      expect(compounds.length, 2);
    });

    test(
        "should return a smaller number of compounds if there are no more fitting the requirements",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [
            Compounds.Apfelkuchen.withFrequencyClass(1),
            Compounds.Kuchenform.withFrequencyClass(5)
          ]);
      final compounds =
          await sut.getRandomCompounds(count: 2, maxFrequencyClass: 1);
      expect(compounds.length, 1);
    });

    test(
        "should return compounds with all frequency classes if maxFrequencyClass is null",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [
            Compounds.Apfelkuchen.withFrequencyClass(1),
            Compounds.Kuchenform.withFrequencyClass(5),
            Compounds.Krankenhaus.withFrequencyClass(null),
          ]);
      final compounds =
          await sut.getRandomCompounds(count: 3, maxFrequencyClass: null);
      expect(compounds.length, 3);
    });

    test("should return random compounds", () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer(
          (_) async => [Compounds.Apfelkuchen, Compounds.Kuchenform]);
      final returnedCompounds = [];
      for (var i = 0; i < 20; i++) {
        // this test will fail once in 2^20 / 2 times ~ 1 in 0.5 million times
        final compounds =
            await sut.getRandomCompounds(count: 1, maxFrequencyClass: null);
        returnedCompounds.add(compounds.first);
      }
      expect(returnedCompounds,
          containsAll([Compounds.Apfelkuchen, Compounds.Kuchenform]));
    });

    test(
        "should return the same random compounds in the same order if called multiple times with the same seed",
        () async {
      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => Compounds.all);
      final returnedCompounds = [];
      for (var i = 0; i < 20; i++) {
        final compounds = await sut.getRandomCompounds(
            count: 3, maxFrequencyClass: null, seed: 1);
        returnedCompounds.add(compounds.first);
      }
      expect(returnedCompounds.toSet().length, 1);
    });
  });

  group("getCompoundsByFrequencyClass", () {
    test("should return all compounds with the given frequency class",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [
            Compounds.Apfelkuchen.withFrequencyClass(1),
            Compounds.Kuchenform.withFrequencyClass(5),
            Compounds.Krankenhaus.withFrequencyClass(null),
          ]);
      final compounds = await sut.getCompoundsByFrequencyClass(5);
      expect(compounds, [
        Compounds.Apfelkuchen.withFrequencyClass(1),
        Compounds.Kuchenform.withFrequencyClass(5)
      ]);
    });
  });

  group("getCompoundsByCompactFrequencyClass", () {
    test("should return all compounds with the given frequency class",
        () async {
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [
            Compounds.Apfelkuchen.withCompactFrequencyClass(
                CompactFrequencyClass.easy),
            Compounds.Kuchenform.withCompactFrequencyClass(
                CompactFrequencyClass.medium),
            Compounds.Krankenhaus.withCompactFrequencyClass(
                CompactFrequencyClass.hard),
          ]);
      final compounds = await sut
          .getCompoundsByCompactFrequencyClass(CompactFrequencyClass.medium);
      expect(compounds, [
        Compounds.Apfelkuchen.withCompactFrequencyClass(
            CompactFrequencyClass.easy),
        Compounds.Kuchenform.withCompactFrequencyClass(
            CompactFrequencyClass.medium)
      ]);
    });
  });
}
