import 'package:kompositum/data/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

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

  group("blockedCompounds", ()
  {
    test("should return the saved compound names", () async {
      final compounds = [Compounds.Apfelbaum, Compounds.Schneemann];
      await sut.storeBlockedCompounds(compounds);
      nameToCompound(String name) =>
          Future.value(Compounds.all.firstWhere((compound) => compound.name == name));
      final result = await sut.getBlockedCompounds(nameToCompound);
      expect(result, compounds);
    });

    test("should return the saved compound names after startup", () async {
      SharedPreferences.setMockInitialValues({"blockedCompounds": ["Apfelbaum", "Schneemann"]});
      nameToCompound(String name) =>
          Future.value(Compounds.all.firstWhere((compound) => compound.name == name));
      final result = await sut.getBlockedCompounds(nameToCompound);
      expect(result, [Compounds.Apfelbaum, Compounds.Schneemann]);
    });

    test("should return an empty list as a default value", () async {
      SharedPreferences.setMockInitialValues({});
      nameToCompound(String name) =>
          Future.value(Compounds.all.firstWhere((compound) => compound.name == name));
      final result = await sut.getBlockedCompounds(nameToCompound);
      expect(result, []);
    });
  });

}