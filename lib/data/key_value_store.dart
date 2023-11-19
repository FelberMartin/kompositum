
import 'package:shared_preferences/shared_preferences.dart';

import 'compound.dart';

class KeyValueStore {

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

  Future<void> storeAdventOpened(List<bool> isDayOpened) async {
    final stringList = isDayOpened.map((e) => e.toString()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("adventOpened", stringList);
  }

  Future<List<bool>> getAdventOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList("adventOpened") ?? List.generate(24, (index) => "false");
    return stringList.map((e) => e == "true").toList();
  }

  Future<void> storeAdventCompleted(List<bool> isDayCompleted) async {
    final stringList = isDayCompleted.map((e) => e.toString()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("adventCompleted", stringList);
  }

  Future<List<bool>> getAdventCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList("adventCompleted") ?? List.generate(24, (index) => "false");
    return stringList.map((e) => e == "true").toList();
  }


}