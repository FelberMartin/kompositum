
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/game/modi/classic/generator/classic_level_content.dart';
import 'package:kompositum/game/swappable_detector.dart';

Matcher isNotInList(List<dynamic> expected) => _IsNotInList(expected);

// A custom matcher for testing whether an object is not in a list.
class _IsNotInList<T> extends Matcher {
  final List<T> _list;

  _IsNotInList(this._list);

  @override
  Description describe(Description description) {
    return description.add("is not in $_list");
  }

  @override
  bool matches(Object? item, Map matchState) {
    return !_list.contains(item);
  }
}

/**
 * This function is used to pump the widget tree multiple times and does NOT
 * wait for the animations to finish (in contrast to pumpAndSettle).
 */
Future<void> nonBlockingPump(WidgetTester tester, [int times = 5]) async {
  for (int i = 0; i < times; i++) { await tester.pump(Duration(seconds: 1)); }
}


// Extension on ClassicGameLevel to make it easier to create a level with a list of compounds
extension ClassicGameLevelExtension on ClassicGameLevel {

  static ClassicGameLevel of(List<Compound> compounds, {
    int maxShownComponentCount = 9,
    int minSolvableCompoundsInPool = 1,
    List<Swappable> swappableCompounds = const [],
  }) {
    final levelContent = ClassicLevelContent(compounds);
    return ClassicGameLevel(
      levelContent,
      maxShownComponentCount: maxShownComponentCount,
      minSolvableCompoundsInPool: minSolvableCompoundsInPool,
      swappableCompounds: swappableCompounds,
    );
  }
}