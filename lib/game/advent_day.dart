import 'package:kompositum/game/pool_game_level.dart';

import '../data/compound.dart';

class AdventDay {

  final int day;
  final List<LevelConfig> levelConfigs;
  final String imagePath;

  const AdventDay(this.day, this.levelConfigs, this.imagePath);

  static AdventDay fromJson(Map<String, dynamic> json) {
    final day = json["day"] as int;
    final imagePath = json["image"] as String;
    final levelConfigs = <LevelConfig>[];
    for (final levelData in json["data"]) {
      final config = PoolGameLevelConfig.fromJson(levelData);
      levelConfigs.add(config);
    }
    if (json["sentence"] != null) {
      final config = SentenceLevelConfig.fromJson(json["sentence"]);
      levelConfigs.add(config);
    }

    return AdventDay(day, levelConfigs, imagePath);
  }

}

abstract class LevelConfig {

  GameLevel getLevel();

}

class PoolGameLevelConfig implements LevelConfig {

  final List<Compound> compounds;

  const PoolGameLevelConfig(this.compounds);

  static PoolGameLevelConfig fromJson(List<dynamic> json) {
    final compounds = json.map((e) => Compound(name: e[0], modifier: e[1], head: e[2])).toList();
    return PoolGameLevelConfig(compounds);
  }

  @override
  PoolGameLevel getLevel() {
    return PoolGameLevel(compounds, maxShownComponentCount: 11);
  }
}

class SentenceLevelConfig implements LevelConfig {

  final String sentence;
  final List<String> words;
  final String separator;

  const SentenceLevelConfig(this.sentence, this.words, this.separator);

  static SentenceLevelConfig fromJson(Map<String, dynamic> json) {
    final sentence = json["total"] as String;
    final words = sentence.split(json["separator"] as String);
    return SentenceLevelConfig(sentence, words, json["separator"] as String);
  }

  @override
  GameLevel getLevel() {
    return SentenceGameLevel(sentence, words, separator);
  }

}