
import 'package:flutter/material.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/widgets/home/dialogs/daily_goals_update_dialog.dart';
import 'package:kompositum/widgets/home/dialogs/pre_redesign_update_dialog.dart';

class UpdateDialog {
  final Widget dialog;
  final String identifier;
  final String version;

  UpdateDialog({
    required this.dialog,
    required this.identifier,
    required this.version,
  });
}

class UpdateManager {

  static List<UpdateDialog> updateDialogs = [
    UpdateDialog(
      dialog: const DailyGoalsUpdateDialog(),
      identifier: "dailyGoals",
      version: "1.2.0",
    ),
    UpdateDialog(   // Inform the user about the upcoming redesign
      dialog: const PreRedesignUpdateDialog(),
      identifier: "preRedesign",
      version: "1.2.2",
    ),
  ];

  final AppVersionProvider appVersionProvider;
  final KeyValueStore keyValueStore;
  Function(Widget)? animateDialog;

  UpdateManager({
    required this.appVersionProvider,
    required this.keyValueStore,
  });

  Future<void> checkForUpdates() async {
    for (final updateDialog in updateDialogs) {
      final shouldShowDialog = await _shouldShowUpdateDialog(updateDialog);
      if (shouldShowDialog) {
        await _showUpdateDialog(updateDialog);
      }
    }
  }

  Future<bool> _shouldShowUpdateDialog(UpdateDialog update) async {
    final shownBefore = await keyValueStore.wasUpdateDialogShown(update);
    if (shownBefore) {
      return false;
    }

    final didAppVersionChange = await appVersionProvider.didAppVersionChange;
    final appVersion = await appVersionProvider.getAppVersion();
    return didAppVersionChange && appVersion == update.version;
  }

  Future<void> _showUpdateDialog(UpdateDialog update) async {
    animateDialog?.call(update.dialog);
    await keyValueStore.storeUpdateDialogAsShown(update);
  }

}