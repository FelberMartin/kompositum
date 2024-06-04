import 'package:kompositum/data/key_value_store.dart';
import 'package:package_info_plus/package_info_plus.dart';


/// Set to `true` if the app is built in production mode and to `false`
/// otherwise (e.g. in development or profile mode).
const bool isProduction = bool.fromEnvironment('dart.vm.product');

class AppVersionProvider {

  static const String noAppVersion = "0.0.0";

  final KeyValueStore keyValueStore;

  late Future<bool> _didAppVersionChange;
  Future<bool> get didAppVersionChange => _didAppVersionChange;

  AppVersionProvider(this.keyValueStore) {
    _didAppVersionChange = _checkAppVersion();
  }

  /// Returns the current app version. Example: "1.0.0"
  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<bool> _checkAppVersion() async {
    final currentVersion = await keyValueStore.getPreviousAppVersion();
    final newVersion = await getAppVersion();
    if (currentVersion != newVersion) {
      print("App version changed from $currentVersion to $newVersion");
      await keyValueStore.storeAppVersion(newVersion);

      if (currentVersion != noAppVersion) {
        return true;
      } else {
        // First app start
        return false;
      }
    }
    return false;
  }
}