// Create a data class Compound that has the following properties:
// - name (String)
// - modifier (String)
// - head (double)

import 'package:kompositum/data/models/unique_component.dart';

import 'compact_frequency_class.dart';

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

  const Compound({
    required this.name,
    required this.modifier,
    required this.head,
    this.frequencyClass,
  });

  List<String> getComponents() {
    return [modifier, head];
  }

  bool isSolvedBy(List<UniqueComponent> components) {
    final modifiers = components.where((component) => component.text == modifier).toList();
    final heads = components.where((component) => component.text == head).toList();
    final combined = (modifiers + heads).toSet();
    if (combined.length == 2) {
      return true;
    }
    return false;
  }

  bool isOnlyPartiallySolvedBy(List<UniqueComponent> components) {
    final modifiers = components.where((component) => component.text == modifier).toList();
    final heads = components.where((component) => component.text == head).toList();
    final combined = (modifiers + heads).toSet();
    if (combined.length == 1) {
      return true;
    }
    return false;
  }

  Compound withFrequencyClass(int? frequencyClass) {
    return Compound(
      name: name,
      modifier: modifier,
      head: head,
      frequencyClass: frequencyClass,
    );
  }

  Compound withCompactFrequencyClass(CompactFrequencyClass frequencyClass) {
    return Compound(
      name: name,
      modifier: modifier,
      head: head,
      frequencyClass: frequencyClass.maxFrequencyClass,
    );
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

  @override
  int get hashCode =>
      name.hashCode ^
      modifier.hashCode ^
      head.hashCode ^
      frequencyClass.hashCode;



}
