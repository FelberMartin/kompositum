import 'package:flutter/widgets.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:mocktail/mocktail.dart';
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

    when(() => compoundOrigin.getCompounds())
        .thenAnswer((_) async => Compounds.all);

    databaseInitializer = DatabaseInitializer(compoundOrigin: compoundOrigin, reset: true, path: 'test/data');
    sut = DatabaseInterface(databaseInitializer);
  });

  tearDown(() {
    sut.close();
  });

  group("getCompoundCount", () {
    test(
      "should return the number of compounds",
      () async {
        final count = await sut.getCompoundCount();
        expect(count, Compounds.all.length);
      },
    );
  });

  group("getAllCompounds", () {
    test(
      "should return all compounds",
      () async {
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

  group("getCompoundByName", () {
    setUp(() => {
      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => [Compounds.Apfelbaum])
    });

    test(
      "should return the compound with the given name",
      () async {
        final compound = await sut.getCompoundByName("Apfelbaum");
        expect(compound, Compounds.Apfelbaum);
      },
    );

    test(
      "should return null if no compound with the given name exists",
      () async {
        final compound = await sut.getCompoundByName("Sandburg");
        expect(compound, isNull);
      },
    );
  });

  group("getCompoundsByFrequencyClass", () {
    test("should return all compounds with the given frequency class",
        () async {
      await sut.close();

      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [
            Compounds.Apfelkuchen.withFrequencyClass(1),
            Compounds.Kuchenform.withFrequencyClass(5),
            Compounds.Krankenhaus.withFrequencyClass(null),
          ]);
      databaseInitializer = DatabaseInitializer(compoundOrigin: compoundOrigin, reset: true, path: 'test/data');
      sut = DatabaseInterface(databaseInitializer);

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
      await sut.close();
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [
            Compounds.Apfelkuchen.withCompactFrequencyClass(
                CompactFrequencyClass.easy),
            Compounds.Kuchenform.withCompactFrequencyClass(
                CompactFrequencyClass.medium),
            Compounds.Krankenhaus.withCompactFrequencyClass(
                CompactFrequencyClass.hard),
          ]);
      databaseInitializer = DatabaseInitializer(compoundOrigin: compoundOrigin, reset: true, path: 'test/data');
      sut = DatabaseInterface(databaseInitializer);

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
