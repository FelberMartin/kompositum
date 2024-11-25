
import 'package:kompositum/data/models/compact_frequency_class.dart';

class Difficulty {
  final String uiText;
  final CompactFrequencyClass frequencyClass;
  final int maxShownComponentCount;
  final int minSolvableCompoundsInPool;

  const Difficulty._({
    required this.uiText,
    required this.frequencyClass,
    required this.maxShownComponentCount,
    this.minSolvableCompoundsInPool = 1,
  });

  static const Difficulty easy = Difficulty._(
    uiText: "Einfach",
    frequencyClass: CompactFrequencyClass.easy,
    maxShownComponentCount: 8,
    minSolvableCompoundsInPool: 2,
  );

  static const Difficulty medium = Difficulty._(
    uiText: "Mittel",
    frequencyClass: CompactFrequencyClass.medium,
    maxShownComponentCount: 9,
  );

  static const Difficulty hard = Difficulty._(
    uiText: "Schwer",
    frequencyClass: CompactFrequencyClass.hard,
    maxShownComponentCount: 11,
  );

  static const List<Difficulty> values = [
    easy,
    medium,
    hard,
  ];

  int get index => values.indexOf(this);

  static Difficulty fromIndex(int index) {
    return values[index];
  }

}