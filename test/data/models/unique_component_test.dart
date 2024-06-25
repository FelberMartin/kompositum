
import 'package:flutter_test/flutter_test.dart';
import 'package:kompositum/data/models/unique_component.dart';

void main() {
  group("matches", () {
    test("returns true even if the case of the texts differ", () {
      final component = UniqueComponent("Krank");
      expect(component.matches("krank"), isTrue);
    });

    test("returns false if the texts differ", () {
      final component = UniqueComponent("Krank");
      expect(component.matches("Haus"), isFalse);
    });

  });
}