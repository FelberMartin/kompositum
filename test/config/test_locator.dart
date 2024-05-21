import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/modi/pool/generator/compound_pool_generator.dart';
import 'package:kompositum/game/modi/pool/generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/util/device_info.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/util/tutorial_manager.dart';

import '../mocks/mock_apper_version_provider.dart';
import '../mocks/mock_device_info.dart';
import '../mocks/mock_notification_manager.dart';

final locator = GetIt.instance;

Future<void> setupTestLocator() async {
  locator.registerSingleton<CompoundOrigin>(CompoundOrigin("assets/final_compounds.csv"));

  final docsDir = Directory("");

  locator.registerSingleton<KeyValueStore>(KeyValueStore());
  locator.registerSingleton<AppVersionProvider>(MockAppVersionProvider());
  locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(
      compoundOrigin: locator<CompoundOrigin>(),
      appVersionProvider: locator<AppVersionProvider>(),
      path: docsDir.path,
      forceReset: true
  ));
  locator.registerSingleton<DatabaseInterface>(DatabaseInterface(locator<DatabaseInitializer>()));
  locator.registerSingleton<CompoundPoolGenerator>(GraphBasedPoolGenerator(locator<DatabaseInterface>()));
  locator.registerSingleton<LevelProvider>(LogarithmicLevelProvider());

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager());
  locator.registerSingleton<TutorialManager>(TutorialManager(locator<KeyValueStore>()));
  locator.registerSingleton<NotificationManager>(MockNotificationManager());
  locator.registerSingleton<DailyNotificationScheduler>(
      DailyNotificationScheduler(locator<NotificationManager>(), locator<KeyValueStore>())
  );

  locator.registerSingleton<DeviceInfo>(MockDeviceInfo());
  locator.registerSingleton<DailyGoalSetManager>(DailyGoalSetManager(locator<KeyValueStore>(), locator<DeviceInfo>()));
}
