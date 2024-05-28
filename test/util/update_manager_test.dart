import 'package:flutter/material.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/util/update_manager.dart';
import 'package:kompositum/widgets/home/dialogs/daily_goals_update_dialog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../mocks/mock_apper_version_provider.dart';

void main() {
  late UpdateManager sut;
  KeyValueStore keyValueStore = KeyValueStore();
  MockAppVersionProvider appVersionProvider = MockAppVersionProvider();

  final List<Widget> _animateDialogParams = [];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _animateDialogParams.clear();

    sut = UpdateManager(
      appVersionProvider: appVersionProvider,
      keyValueStore: keyValueStore,
    );
    sut.animateDialog = (dialog) {
      _animateDialogParams.add(dialog);
    };
  });

  group("DailyGoals", () {
    test("should not show daily goals dialog when app version did not change", () async {
      appVersionProvider.didAppVersionChange = Future.value(false);

      await sut.checkForUpdates();
      expect(_animateDialogParams, isEmpty);
    });

    test("should not show the dialog if the new app version is other than 1.2.0", () {
      appVersionProvider.didAppVersionChange = Future.value(true);
      appVersionProvider.appVersion = "1.1.0";

      sut.checkForUpdates();
      expect(_animateDialogParams, isEmpty);
    });

    test("should not show dialog when the dialog was already shown", () async {
      appVersionProvider.didAppVersionChange = Future.value(true);
      appVersionProvider.appVersion = "1.2.0";
      await keyValueStore.storeUpdateDialogAsShown(UpdateDialog.dailyGoals);

      await sut.checkForUpdates();
      expect(_animateDialogParams, isEmpty);
    });

    test("should show daily goals dialog when app version changed to 1.2.0", () async {
      appVersionProvider.didAppVersionChange = Future.value(true);
      appVersionProvider.appVersion = "1.2.0";

      await sut.checkForUpdates();
      expect(_animateDialogParams, isNotEmpty);
      expect(_animateDialogParams[0], isA<DailyGoalsUpdateDialog>());
    });
  });
}