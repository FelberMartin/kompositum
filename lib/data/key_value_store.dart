
import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStore {

  Future<void> storeLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("level", level);
  }

  Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("level") ?? 1;
  }
}