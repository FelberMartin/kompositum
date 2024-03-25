import 'dart:convert';

import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/level_loader.dart';
import 'package:kompositum/game/pool_game_level.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

void main() {

  LevelLoader createSut(PoolGameLevel poolGameLevel) {
    SharedPreferences.setMockInitialValues({
      "level": 10,
      "classicPoolGameLevel": jsonEncode(poolGameLevel.toJson()),
    });
    return LevelLoader(KeyValueStore());
  }

  test("should return the loaded level", () async {
    final poolGameLevel = PoolGameLevel([Compounds.Krankenhaus]);
    final sut = createSut(poolGameLevel);
    final result = await sut.loadLevel();
    expect(result!.shownComponents, poolGameLevel.shownComponents);
  });

  test("should return null if there is no stored level", () async {
    SharedPreferences.setMockInitialValues({
      "level": 10,
    });
    final sut = LevelLoader(KeyValueStore());
    final result = await sut.loadLevel();
    expect(result, null);
  });

  test('should skip the level if the stored game has no components', () async {
    final poolGameLevel = PoolGameLevel([]);
    final sut = createSut(poolGameLevel);
    expect(sut.loadLevel(), throwsException);
  });

  test('should skip the level if the stored game has odd component count', () async {
    final poolGameLevel = PoolGameLevel([Compounds.Krankenhaus]);
    poolGameLevel.shownComponents.add(UniqueComponent("a", 123));
    final sut = createSut(poolGameLevel);
    expect(sut.loadLevel(), throwsException);
  });

  test("should not skip the level if the stored game has even component count", () async {
    final poolGameLevel = PoolGameLevel([Compounds.Krankenhaus]);
    poolGameLevel.shownComponents.add(UniqueComponent("a", 123));
    poolGameLevel.hiddenComponents.add(UniqueComponent("b", 123));
    final sut = createSut(poolGameLevel);
    final result = await sut.loadLevel();
    expect(result!.shownComponents, poolGameLevel.shownComponents);
  });
}