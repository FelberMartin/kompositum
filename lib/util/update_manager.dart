
import 'package:flutter/material.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/widgets/home/dialogs/daily_goals_update_dialog.dart';

class UpdateDialog {
  static UpdateDialog dailyGoals = UpdateDialog._(
    const DailyGoalsUpdateDialog(),
    "dailyGoals",
    "1.2.0",
  );

  final Widget dialog;
  final String identifier;
  final String version;

  UpdateDialog._(this.dialog, this.identifier, this.version);
}

class UpdateManager {

  final AppVersionProvider appVersionProvider;
  final KeyValueStore keyValueStore;
  Function(Widget)? animateDialog;

  UpdateManager({
    required this.appVersionProvider,
    required this.keyValueStore,
  });

  Future<void> checkForUpdates() async {
    await _checkForDailyGoalsUpdate();
  }

  Future<void> _checkForDailyGoalsUpdate() async {
    final shownBefore = await keyValueStore.wasUpdateDialogShown(UpdateDialog.dailyGoals);
    if (shownBefore) {
      return;
    }

    final didAppVersionChange = await appVersionProvider.didAppVersionChange;
    final appVersion = await appVersionProvider.getAppVersion();
    if (didAppVersionChange && appVersion == UpdateDialog.dailyGoals.version) {
      final updateDialog = UpdateDialog.dailyGoals;
      animateDialog?.call(updateDialog.dialog);
      await keyValueStore.storeUpdateDialogAsShown(updateDialog);
    }
  }



}