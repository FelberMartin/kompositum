
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

  Future<List<Compound>> getBlockedCompounds(Future<Compound?> Function(String) nameToCompound) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedCompoundNames = prefs.getStringList("blockedCompounds") ?? [];
    final blockedCompounds = <Compound>[];
    for (final blockedCompoundName in blockedCompoundNames) {
      final blockedCompound = await nameToCompound(blockedCompoundName);
      if (blockedCompound != null) {
        blockedCompounds.add(blockedCompound);
      }
    }
    return blockedCompounds;
  }
}