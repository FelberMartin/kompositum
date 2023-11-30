import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:test/test.dart';

void main() {
  group("fromCsvLine", () {
    test(
      "should return a compound with the basic values",
          () {
        final compound = CompoundOrigin.fromCsvLine("Krankenhaus,krank,Haus,1.0");
        expect(compound.name, "Krankenhaus");
        expect(compound.modifier, "krank");
        expect(compound.head, "Haus");
        expect(compound.frequencyClass, 1);
      },
    );

    test(
      "should return a compound with null as frequency class if the frequency class is not given",
          () {
        final compound = CompoundOrigin.fromCsvLine("Krankenhaus,krank,Haus,");
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
            "Krankenhaus,krank,Haus,1.0\n"
            "Spielplatz,Spiel,Platz,\n"
            "Schulklasse,Schule,Klasse,1.0";
        final compounds = CompoundOrigin.fromCsvFile(csv);
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
            "Krankenhaus,krank,Haus,1.0\r\n"
            "Spielplatz,Spiel,Platz,\r\n"
            "Schulklasse,Schule,Klasse,1.0";
        final compounds = CompoundOrigin.fromCsvFile(csv);
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
            "Krankenhaus,krank,Haus,1.0\n"
            "\n"
            "Spielplatz,Spiel,Platz,1.0\n"
            "Schulklasse,Schule,Klasse,1.0\n";
        final compounds = CompoundOrigin.fromCsvFile(csv);
        expect(compounds, isNotEmpty);
        expect(compounds.length, 3);
      },
    );
  });

  group("getComponents", () {
    test(
      "should return the components in the csv file",
          () async {
        final expected = [
          const Compound(
            name: "Aalbestand",
            modifier: "Aal",
            head: "Bestand",
            frequencyClass: 22,
          ),
          const Compound(
            name: "Aalfang",
            modifier: "Aal",
            head: "Fang",
            frequencyClass: 20,
          ),
          const Compound(
            name: "Aalfisch",
            modifier: "Aal",
            head: "Fisch",
            frequencyClass: null,
          ),
        ];
        final sut = CompoundOrigin("test/test_data/test_compounds.csv");

        final compounds = await sut.getCompounds();
        expect(compounds, isNotEmpty);
        expect(compounds.length, 3);
        expect(compounds, expected);
      },
    );
  });
}