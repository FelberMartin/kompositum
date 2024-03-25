
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/pool_game_level.dart';
import '../util/tutorial_manager.dart';
import 'models/compound.dart';

class KeyValueStore {

  KeyValueStore() {
    // SharedPreferences.setMockInitialValues({"level": 177});
  }

  Future<void> storeLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("level", level);
  }

  Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("level") ?? 1;
  }

  Future<void> storeBlockedCompounds(List<Compound> compounds) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedCompoundNames = compounds.map((compound) => compound.name).toList();
    await prefs.setStringList("blockedCompounds", blockedCompoundNames);
  }

  Future<List<String>> getBlockedCompoundNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("blockedCompounds") ?? [];
  }

  Future<void> storeStarCount(int starCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("starCount", starCount);
  }

  Future<void> increaseStarCount(int starCount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentStarCount = await getStarCount();
    await prefs.setInt("starCount", currentStarCount + starCount);
  }

  Future<int> getStarCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("starCount") ?? 100;
  }

  Future<void> storeDailiesCompleted(List<DateTime> completedDays) async {
    final prefs = await SharedPreferences.getInstance();
    final completedDaysString = completedDays.map((day) => day.toIso8601String()).toList();
    await prefs.setStringList("completedDays", completedDaysString);
  }

  Future<List<DateTime>> getDailiesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completedDaysString = prefs.getStringList("completedDays") ?? [];
    return completedDaysString.map((dayString) => DateTime.parse(dayString)).toList();
  }

  Future<void> storeClassicPoolGameLevel(PoolGameLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("classicPoolGameLevel", jsonEncode(level.toJson()));
  }

  Future<PoolGameLevel?> getClassicPoolGameLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString("classicPoolGameLevel");
    if (json != null) {
      return PoolGameLevel.fromJson(Map<String, dynamic>.from(jsonDecode(json)));
    }
    return null;
  }

  Future<bool> isFirstLaunch() async {
    final level = await getLevel();
    return level == 1;
  }

  Future<void> storeTutorialPartAsShown(TutorialPart part) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("tutorialPartShown_${part.toString()}", true);
  }

  Future<bool> wasTutorialPartShown(TutorialPart part) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("tutorialPartShown_${part.toString()}") ?? false;
  }

  Future<String> getPreviousAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("previousAppVersion") ?? "1.0.0";
  }

  Future<void> storeAppVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("previousAppVersion", version);
  }
}