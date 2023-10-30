import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'compound.dart';

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
      name: values[0],
      modifier: values[1],
      head: values[2],
      frequencyClass: double.tryParse(values[3])?.toInt(),
    );
  }


}
