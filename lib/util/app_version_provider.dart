import 'package:kompositum/data/key_value_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProvider {

  final KeyValueStore keyValueStore;

  var _didAppVersionChange = false;
  bool get didAppVersionChange => _didAppVersionChange;

  AppVersionProvider(this.keyValueStore) {
    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    final currentVersion = await keyValueStore.getPreviousAppVersion();
    final packageInfo = await PackageInfo.fromPlatform();
    final newVersion = packageInfo.version;
    if (currentVersion != newVersion) {
      print("App version changed from $currentVersion to $newVersion");
      await keyValueStore.storeAppVersion(newVersion);
      _didAppVersionChange = true;
    }
  }
}