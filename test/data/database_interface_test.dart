import 'package:flutter/widgets.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
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
    setUp(() => {
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

    test(
      "should not be case sensitive",
      () async {
        final compound = await sut.getCompound("apfel", "baum");
        expect(compound, Compounds.Apfelbaum);
      },
    );
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
}
