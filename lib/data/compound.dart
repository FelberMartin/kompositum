// Create a data class Compound that has the following properties:
// - name (String)
// - modifier (String)
// - head (double)

class Compound {
  // The full name of the compound e.g. "Krankenhaus"
  final String name;

  // The modifier of the compound e.g. "krank"
  final String modifier;

  // The head of the compound e.g. "Haus"
  final String head;

  // The frequency class of the compound ranging from 0 (very frequent) to 28 (very infrequent)
  final int? frequencyClass;

  static Compound fromMap(Map<String, dynamic> map) {
    return Compound(
      name: map['name'] as String,
      modifier: map['modifier'] as String,
      head: map['head'] as String,
      frequencyClass: map['frequencyClass'] as int?,
    );
  }

  static Compound fromCsvLine(String line) {
    final values = line.split(",");
    return Compound(
      name: values[0],
      modifier: values[1],
      head: values[2],
      frequencyClass: int.tryParse(values[3]),
    );
  }

  static List<Compound> fromCsvFile(String csv_content) {
    var lines = csv_content.split("\n").skip(1);
    lines = lines.where((line) => line.isNotEmpty);
    return lines.map((line) => Compound.fromCsvLine(line)).toList();
  }

  const Compound({
    required this.name,
    required this.modifier,
    required this.head,
    this.frequencyClass,
  });

  List<String> getComponents() {
    return [modifier, head];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'modifier': modifier,
      'head': head,
      'frequencyClass': frequencyClass,
    };
  }

  @override
  String toString() {
    return 'Compound{name: $name, modifier: $modifier, head: $head, frequencyClass: $frequencyClass}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Compound &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          modifier == other.modifier &&
          head == other.head &&
          frequencyClass == other.frequencyClass;


}
