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
        "should return a list of compounds",
        () {
          const csv = "name,modifier,head,frequency_class\n"
              "Krankenhaus,krank,Haus,1\n"
              "Spielplatz,Spiel,Platz,\n"
              "Schulklasse,Schule,Klasse,1";
          final compounds = Compound.fromCsvFile(csv);
          expect(compounds, isNotEmpty);
          expect(compounds.length, 3);

          expect(compounds.first.name, "Krankenhaus");
          expect(compounds.first.modifier, "krank");
          expect(compounds.first.head, "Haus");
          expect(compounds.first.frequencyClass, 1);
        },
      );

      test(
        "should also work with carrige return file endings",
        () {
          const csv = "name,modifier,head,frequency_class\r\n"
              "Krankenhaus,krank,Haus,1\r\n"
              "Spielplatz,Spiel,Platz,\r\n"
              "Schulklasse,Schule,Klasse,1";
          final compounds = Compound.fromCsvFile(csv);
          expect(compounds.length, 3);

          expect(compounds.first.name, "Krankenhaus");
          expect(compounds.first.modifier, "krank");
          expect(compounds.first.head, "Haus");
          expect(compounds.first.frequencyClass, 1);

          expect(compounds[1].frequencyClass, null);
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
