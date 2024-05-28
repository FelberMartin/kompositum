import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/game_event/game_event_stream.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/classic_level_setup_provider.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/classic/generator/graph_based_classic_level_content_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/util/device_info.dart';
import 'package:kompositum/util/feature_lock_manager.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:kompositum/util/update_manager.dart';

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
  locator.registerSingleton<LevelContentGenerator>(GraphBasedClassicLevelContentGenerator(locator<DatabaseInterface>()));
  locator.registerSingleton<LevelSetupProvider>(LogarithmicLevelSetupProvider());

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager());
  locator.registerSingleton<TutorialManager>(TutorialManager(locator<KeyValueStore>()));
  locator.registerSingleton<NotificationManager>(MockNotificationManager());
  locator.registerSingleton<DailyNotificationScheduler>(
      DailyNotificationScheduler(locator<NotificationManager>(), locator<KeyValueStore>())
  );
  locator.registerSingleton<UpdateManager>(UpdateManager(
    appVersionProvider: locator<AppVersionProvider>(),
    keyValueStore: locator<KeyValueStore>(),
  ));
  locator.registerSingleton<FeatureLockManager>(FeatureLockManager(
    gameEventStream: GameEventStream.instance.stream,
    keyValueStore: locator<KeyValueStore>(),
  ));

  locator.registerSingleton<DeviceInfo>(DeviceInfo());
  locator.registerSingleton<DailyGoalSetManager>(DailyGoalSetManager(
    keyValueStore: locator<KeyValueStore>(),
    deviceInfo: locator<DeviceInfo>(),
    featureLockManager: locator<FeatureLockManager>(),
  ));
}
