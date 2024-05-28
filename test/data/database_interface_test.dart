import 'package:flutter/widgets.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../mocks/mock_apper_version_provider.dart';
import '../mocks/mock_compound_origin.dart';
import '../test_data/compounds.dart';

void main() {
  late DatabaseInterface sut;
  late DatabaseInitializer databaseInitializer;
  late MockCompoundOrigin compoundOrigin;
  final AppVersionProvider appVersionProvider = MockAppVersionProvider();

  DatabaseInitializer _createDatabaseInitializer({bool reset = true}) {
    return DatabaseInitializer(
      compoundOrigin: compoundOrigin,
      appVersionProvider: appVersionProvider,
      path: "test/test_data",
      forceReset: reset,
    );
  }

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    compoundOrigin = MockCompoundOrigin();

    when(() => compoundOrigin.getCompounds())
        .thenAnswer((_) async => Compounds.all);

    SharedPreferences.setMockInitialValues({});
    databaseInitializer = _createDatabaseInitializer();
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

    test(
      "should return the compound with case insensitive", () async {
        await sut.close();
        final compound = Compound(id: 0, name: "Krankenhaus", modifier: "Kranke", head: "Haus", frequencyClass: 1);

        when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [compound]);
        databaseInitializer = _createDatabaseInitializer();
        sut = DatabaseInterface(databaseInitializer);

        final result = await sut.getCompound("kranke", "haus", caseSensitive: false);
        expect(result, compound);
      });

    test(
      "should return the compound with the more frequent frequency class if there are multiple ones",
          () async {
            await sut.close();
            final compound1 = Compound(id: 0, name: "Nationalelf", modifier: "national", head: "elf", frequencyClass: 4);
            final compound2 = Compound(id: 0, name: "Nationalelf", modifier: "national", head: "Elf", frequencyClass: 1);
            when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [compound1, compound2]);
            databaseInitializer = _createDatabaseInitializer();
            sut = DatabaseInterface(databaseInitializer);

            final compound = await sut.getCompound("national", "elf", caseSensitive: false);
            expect(compound, compound2);
          });

    test(
      "edgeCase Überflussgesellschaft: should NOT return the compound with umlauts (with case insensitive)",
          () async {
            // The objectbox caseSensitivity only works for ASCII characters, so not for the German umlauts.
            // This edgecase is tackled in the graph_based_pool_generator_test.dart
            await sut.close();
            final compound = Compound(id: 0, name: "Überflussgesellschaft", modifier: "Überfluss", head: "Gesellschaft", frequencyClass: 1);
            when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [compound]);
            databaseInitializer = _createDatabaseInitializer();
            sut = DatabaseInterface(databaseInitializer);

            final result = await sut.getCompound("überfluss", "gesellschaft", caseSensitive: false);
            expect(result, null);
          });

    test("getCompoundSafe: edgeCase Überflussgesellschaft: should return the compound with umlauts", () async {
      await sut.close();
      final compound = Compound(id: 0, name: "Überflussgesellschaft", modifier: "Überfluss", head: "Gesellschaft", frequencyClass: 1);
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [compound]);
      databaseInitializer = _createDatabaseInitializer();
      sut = DatabaseInterface(databaseInitializer);

      final result = await sut.getCompoundSafe("überfluss", "gesellschaft");
      expect(result, compound);
    });

    test(
        "edgeCase ß: should return the compound with special characters",
            () async {
          await sut.close();
          final compound = Compound(id: 0, name: "Fußball", modifier: "Fuß", head: "Ball", frequencyClass: 1);
          when(() => compoundOrigin.getCompounds()).thenAnswer((_) async => [compound]);
          databaseInitializer = _createDatabaseInitializer();
          sut = DatabaseInterface(databaseInitializer);

          final result = await sut.getCompound("fuß", "ball", caseSensitive: false);
          expect(result, compound);
        });

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

    test("should return the compound with the more frequent frequency class if there are multiple ones", () async {
      await sut.close();
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async =>
      [
        Compounds.Krankenhaus.withFrequencyClass(1),
        Compounds.Krankenhaus_v2.withFrequencyClass(5),
      ]);
      databaseInitializer = _createDatabaseInitializer();
      sut = DatabaseInterface(databaseInitializer);

      final compound = await sut.getCompoundByName("Krankenhaus");
      expect(compound, Compounds.Krankenhaus);
    });

    test("should return the compound with the more frequent frequency class if there are multiple ones", () async {
      await sut.close();
      when(() => compoundOrigin.getCompounds()).thenAnswer((_) async =>
      [
        Compounds.Krankenhaus_v2.withFrequencyClass(null),
        Compounds.Krankenhaus.withFrequencyClass(1),
      ]);
      databaseInitializer = _createDatabaseInitializer();
      sut = DatabaseInterface(databaseInitializer);

      final compound = await sut.getCompoundByName("Krankenhaus");
      expect(compound, Compounds.Krankenhaus);
    });
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
      databaseInitializer = _createDatabaseInitializer();
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
      databaseInitializer = _createDatabaseInitializer();
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
