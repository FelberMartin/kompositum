import 'dart:convert';

import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/game/stored_level_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';
import '../test_util.dart';

void main() {

  StoredLevelLoader createSut(ClassicGameLevel classicGameLevel) {
    SharedPreferences.setMockInitialValues({
      "level": 10,
      "classicClassicGameLevel": jsonEncode(classicGameLevel.toJson()),
    });
    return StoredLevelLoader(KeyValueStore());
  }

  test("should return the loaded level", () async {
    final classicGameLevel = ClassicGameLevelExtension.of([Compounds.Krankenhaus]);
    final sut = createSut(classicGameLevel);
    final result = await sut.loadLevel();
    expect(result!.shownComponents, classicGameLevel.shownComponents);
  });

  test("should return null if there is no stored level", () async {
    SharedPreferences.setMockInitialValues({
      "level": 10,
    });
    final sut = StoredLevelLoader(KeyValueStore());
    final result = await sut.loadLevel();
    expect(result, null);
  });

  test('should skip the level if the stored game has no components', () async {
    final classicGameLevel = ClassicGameLevelExtension.of([]);
    final sut = createSut(classicGameLevel);
    expect(sut.loadLevel(), throwsException);
  });

  test('should skip the level if the stored game has odd component count', () async {
    final classicGameLevel = ClassicGameLevelExtension.of([Compounds.Krankenhaus]);
    classicGameLevel.shownComponents.add(UniqueComponent("a"));
    final sut = createSut(classicGameLevel);
    expect(sut.loadLevel(), throwsException);
  });

  test("should not skip the level if the stored game has even component count", () async {
    final classicGameLevel = ClassicGameLevelExtension.of([Compounds.Krankenhaus]);
    classicGameLevel.shownComponents.add(UniqueComponent("a"));
    classicGameLevel.hiddenComponents.add(UniqueComponent("b"));
    final sut = createSut(classicGameLevel);
    final result = await sut.loadLevel();
    expect(result!.shownComponents, classicGameLevel.shownComponents);
  });
}