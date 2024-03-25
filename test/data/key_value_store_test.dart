import 'package:kompositum/data/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

void main() {
  late KeyValueStore sut;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({"test": "true"});
    sut = KeyValueStore();
  });

  test("should not set mockvalues", () async {
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString("test"), "true");
    expect(prefs.getString("level"), null);
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

  group("blockedCompounds", ()
  {
    test("should return the saved compound names", () async {
      final compounds = [Compounds.Apfelbaum, Compounds.Schneemann];
      await sut.storeBlockedCompounds(compounds);
      final result = await sut.getBlockedCompoundNames();
      expect(result, ["Apfelbaum", "Schneemann"]);
    });

    test("should return the saved compound names after startup", () async {
      SharedPreferences.setMockInitialValues({"blockedCompounds": ["Apfelbaum", "Schneemann"]});
      final result = await sut.getBlockedCompoundNames();
      expect(result, ["Apfelbaum", "Schneemann"]);
    });

    test("should return an empty list as a default value", () async {
      SharedPreferences.setMockInitialValues({});
      final result = await sut.getBlockedCompoundNames();
      expect(result, []);
    });

    test("should return a list of the names of the compounds", () async {
      final compounds = [Compounds.Apfelbaum, Compounds.Schneemann];
      await sut.storeBlockedCompounds(compounds);
      final result = await sut.getBlockedCompoundNames();
      expect(result, ["Apfelbaum", "Schneemann"]);
    });
  });

}