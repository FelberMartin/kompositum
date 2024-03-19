import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models/compound.dart';

class CompoundOrigin {
  final String csvFilePath;

  CompoundOrigin(this.csvFilePath);

  Future<List<Compound>> getCompounds() {
    WidgetsFlutterBinding.ensureInitialized();
    return rootBundle.loadString(csvFilePath).then((csv) {
      return fromCsvFile(csv);
    });
  }

  static List<Compound> fromCsvFile(String csvContent) {
    var lines = csvContent.split("\n").skip(1);
    lines = lines.where((line) => line.isNotEmpty);
    return lines.map((line) => fromCsvLine(line)).toList();
  }

  static Compound fromCsvLine(String line) {
    final values = line.split(",");
    return Compound(
      id: 0,
      name: values[0],
      modifier: values[1],
      head: values[2],
      frequencyClass: double.tryParse(values[3])?.toInt(),
    );
  }
}

class BlockedCompoundOrigin {

  // TODO: CompoundOrigin should already add the reported compounds and remove the blocked ones.

  Future<List<String>> getCompoundNames() {
    WidgetsFlutterBinding.ensureInitialized();
    return rootBundle.loadString("assets/blocked_compounds.csv").then((csv) {
      // Return a list of the strings in the csv file. They are separated by newlines.
      // The the file has no header, so we don't skip the first line.
      return csv.split("\n").toList();
    });
  }
}

