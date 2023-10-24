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

  const Compound({
    required this.name,
    required this.modifier,
    required this.head,
  });

  List<String> getComponents() {
    return [modifier, head];
  }
}
