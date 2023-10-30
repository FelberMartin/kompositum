import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kompositum/data/compound.dart';
import 'package:test/test.dart';

void main() {
  group("fromMap", () {
      test(
        "should return a compound with the given values",
        () {
          final map = {
            "name": "Krankenhaus",
            "modifier": "krank",
            "head": "Haus",
            "frequencyClass": 1,
          };
          final compound = Compound.fromMap(map);
          expect(compound.name, "Krankenhaus");
          expect(compound.modifier, "krank");
          expect(compound.head, "Haus");
          expect(compound.frequencyClass, 1);
        },
      );

      test(
        "should return a compound with null as frequency class if the frequency class is not given",
        () {
          final map = {
            "name": "Krankenhaus",
            "modifier": "krank",
            "head": "Haus",
            "frequency_class": null,
          };
          final compound = Compound.fromMap(map);
          expect(compound.name, "Krankenhaus");
          expect(compound.modifier, "krank");
          expect(compound.head, "Haus");
          expect(compound.frequencyClass, null);
        },
      );
    });

  test(
    "toMap and fromMap work together correctly",
    () {
      const compound = Compound(
        name: "Krankenhaus",
        modifier: "krank",
        head: "Haus",
        frequencyClass: 1,
      );
      final map = compound.toMap();
      final compoundFromMap = Compound.fromMap(map);
      expect(compound, compoundFromMap);
    },
  );

  group("fromCsvLine", () {
    test(
      "should return a compound with the basic values",
      () {
        final compound = Compound.fromCsvLine("Krankenhaus,krank,Haus,1");
        expect(compound.name, "Krankenhaus");
        expect(compound.modifier, "krank");
        expect(compound.head, "Haus");
        expect(compound.frequencyClass, 1);
      },
    );

    test(
      "should return a compound with null as frequency class if the frequency class is not given",
      () {
        final compound = Compound.fromCsvLine("Krankenhaus,krank,Haus,");
        expect(compound.name, "Krankenhaus");
        expect(compound.modifier, "krank");
        expect(compound.head, "Haus");
        expect(compound.frequencyClass, null);
      },
    );

  });

  group("fromCsvFile", () {
      test(
        "read csv file is in the expected format",
        () async {
          WidgetsFlutterBinding.ensureInitialized();
          const expected = "compound,modifier,head,frequency_class\n"
            "Aalbestand,Aal,Bestand,22.0\n"
            "Aalfang,Aal,Fang,20.0\n"
            "Aalfisch,Aal,Fisch,\n";
          final read = await rootBundle.loadString("test/test_data/test_compounds.csv");
          expect(read, expected);
        }
      );

      test(
        "should return a list of compounds",
        () {
          const csv = "name,modifier,head,frequency_class\n"
              "Krankenhaus,krank,Haus,1\n"
              "Spielplatz,Spiel,Platz,1\n"
              "Schulklasse,Schule,Klasse,1\n";
          final compounds = Compound.fromCsvFile(csv);
          expect(compounds, isNotEmpty);
          expect(compounds.length, 3);
        },
      );

      test(
        "can deal with empty lines",
        () {
          const csv = "name,modifier,head,frequency_class\n"
              "Krankenhaus,krank,Haus,1\n"
              "\n"
              "Spielplatz,Spiel,Platz,1\n"
              "Schulklasse,Schule,Klasse,1\n";
          final compounds = Compound.fromCsvFile(csv);
          expect(compounds, isNotEmpty);
          expect(compounds.length, 3);
        },
      );
    });
}
