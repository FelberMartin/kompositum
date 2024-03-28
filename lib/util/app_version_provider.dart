import 'package:kompositum/data/key_value_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProvider {

  final KeyValueStore keyValueStore;

  late Future<bool> _didAppVersionChange;
  Future<bool> get didAppVersionChange => _didAppVersionChange;

  AppVersionProvider(this.keyValueStore) {
    _didAppVersionChange = _checkAppVersion();
  }

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
      return true;
    }
    return false;
  }
}