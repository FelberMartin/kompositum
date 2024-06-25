import 'package:kompositum/data/models/unique_component.dart';
import 'package:objectbox/objectbox.dart';

import 'compact_frequency_class.dart';

@Entity()
class Compound {
  /// The unique identifier of the compound. This will be set by objectbox.
  @Id()
  int id;

  /// The full name of the compound e.g. "Krankenhaus"
  @Index()
  final String name;

  /// The modifier of the compound e.g. "krank"
  final String modifier;

  /// The head of the compound e.g. "Haus"
  final String head;

  /// The frequency class of the compound ranging from 0 (very frequent) to 28 (very infrequent)
  final int? frequencyClass;

  static Compound fromJson(Map<String, dynamic> map) {
    return Compound(
      id: map['id'] as int,
      name: map['name'] as String,
      modifier: map['modifier'] as String,
      head: map['head'] as String,
      frequencyClass: map['frequencyClass'] as int?,
    );
  }

  Compound({
    required this.id,
    required this.name,
    required this.modifier,
    required this.head,
    this.frequencyClass,
  });

  List<String> getComponents() {
    return [modifier, head];
  }

  bool matches(String modifier, String head) {
    return UniqueComponent.textMatches(this.modifier, modifier) &&
        UniqueComponent.textMatches(this.head, head);
  }

  bool isSolvedBy(List<UniqueComponent> components) {
    final matching = _getMatchingModifiersAndHeads(components);
    if (matching.length == 2) {
      return true;
    }
    return false;
  }

  Set<UniqueComponent> _getMatchingModifiersAndHeads(List<UniqueComponent> components) {
    final modifiers = components.where((component) => component.matches(modifier)).toList();
    final heads = components.where((component) => component.matches(head)).toList();
    return (modifiers + heads).toSet();
  }

  bool isOnlyPartiallySolvedBy(List<UniqueComponent> components) {
    final matching = _getMatchingModifiersAndHeads(components);
    if (matching.length == 1) {
      return true;
    }
    return false;
  }

  Compound withFrequencyClass(int? frequencyClass) {
    return Compound(
      id: 0,
      name: name,
      modifier: modifier,
      head: head,
      frequencyClass: frequencyClass,
    );
  }

  Compound withCompactFrequencyClass(CompactFrequencyClass frequencyClass) {
    return Compound(
      id: 0,
      name: name,
      modifier: modifier,
      head: head,
      frequencyClass: frequencyClass.maxFrequencyClass,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modifier': modifier,
      'head': head,
      'frequencyClass': frequencyClass,
    };
  }

  @override
  String toString() {
    return 'Compound{id: $id, name: $name, modifier: $modifier, head: $head, frequencyClass: $frequencyClass}';
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

  @override
  int get hashCode =>
      name.hashCode ^
      modifier.hashCode ^
      head.hashCode ^
      frequencyClass.hashCode;
}
