import 'compound.dart';

class UniqueComponent {

  final String text;
  final int id;

  UniqueComponent(this.text, this.id);

  static List<UniqueComponent> fromCompounds(List<Compound> compounds) {
    final uniqueComponents = <UniqueComponent>[];
    var id = 0;
    for (final compound in compounds) {
      uniqueComponents.add(UniqueComponent(compound.modifier, id++));
      uniqueComponents.add(UniqueComponent(compound.head, id++));
    }
    return uniqueComponents;
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