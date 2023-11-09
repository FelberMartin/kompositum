import 'package:kompositum/data/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  late KeyValueStore sut;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    sut = KeyValueStore();
  });

  group("level", () {
    test("should return the saved level", () async {
      await sut.storeLevel(5);
      final result = await sut.getLevel();
      expect(result, 5);
    });

    test("should return the level that was saved after startup", () async {
      SharedPreferences.setMockInitialValues({"level": 3});
      final result = await sut.getLevel();
      expect(result, 3);
    });

    test("should return 1 as a default value", () async {
      SharedPreferences.setMockInitialValues({});
      final result = await sut.getLevel();
      expect(result, 1);
    });
  });

}