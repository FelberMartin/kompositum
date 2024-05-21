import 'dart:convert';

import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/modi/pool/pool_game_level.dart';
import 'package:kompositum/game/stored_level_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

void main() {

  StoredLevelLoader createSut(PoolGameLevel poolGameLevel) {
    SharedPreferences.setMockInitialValues({
      "level": 10,
      "classicPoolGameLevel": jsonEncode(poolGameLevel.toJson()),
    });
    return StoredLevelLoader(KeyValueStore());
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
    final sut = StoredLevelLoader(KeyValueStore());
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
    poolGameLevel.shownComponents.add(UniqueComponent("a"));
    final sut = createSut(poolGameLevel);
    expect(sut.loadLevel(), throwsException);
  });

  test("should not skip the level if the stored game has even component count", () async {
    final poolGameLevel = PoolGameLevel([Compounds.Krankenhaus]);
    poolGameLevel.shownComponents.add(UniqueComponent("a"));
    poolGameLevel.hiddenComponents.add(UniqueComponent("b"));
    final sut = createSut(poolGameLevel);
    final result = await sut.loadLevel();
    expect(result!.shownComponents, poolGameLevel.shownComponents);
  });
}