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
}
