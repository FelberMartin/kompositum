import 'compound.dart';

class UniqueComponent {

  static int _idCounter = 0;

  final String text;
  late final int id;

  UniqueComponent(this.text) {
    id = _idCounter++;
  }

  static List<UniqueComponent> fromCompound(Compound compound) {
    return [
      UniqueComponent(compound.modifier),
      UniqueComponent(compound.head),
    ];
  }

  static List<UniqueComponent> fromCompounds(List<Compound> compounds) {
    return compounds.expand((compound) => fromCompound(compound)).toList();
  }

  static bool textMatches(String text1, String text2) {
    return text1.toLowerCase() == text2.toLowerCase();
  }

  /// Returns whether the given text matches the text of this component.
  /// Ignores case.
  bool matches(String text) {
    return textMatches(this.text, text);
  }

  @override
  bool operator ==(Object other) {
    return other is UniqueComponent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UniqueComponent{text: $text, id: $id}';
  }

  UniqueComponent.fromJson(Map<String, dynamic> json) :
    text = json['text'],
    id = json['id'];

  Map<String, dynamic> toJson() => {
    'text': text,
    'id': id,
  };
}