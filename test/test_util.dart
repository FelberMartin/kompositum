
import 'package:flutter_test/flutter_test.dart';

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