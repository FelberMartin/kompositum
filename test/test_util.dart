
import 'package:test/test.dart';

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