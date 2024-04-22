import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../data/compound_origin.dart';
import '../data/database_initializer.dart';
import '../data/database_interface.dart';
import '../data/key_value_store.dart';
import '../game/level_provider.dart';
import '../game/pool_generator/compound_pool_generator.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerSingleton<CompoundOrigin>(CompoundOrigin("assets/final_compounds.csv"));

  final docsDir = await getApplicationDocumentsDirectory();

  locator.registerSingleton<KeyValueStore>(KeyValueStore());
  locator.registerSingleton<AppVersionProvider>(AppVersionProvider(locator<KeyValueStore>()));

  locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(
      compoundOrigin: locator<CompoundOrigin>(),
      appVersionProvider: locator<AppVersionProvider>(),
      path: docsDir.path,
      forceReset: false,
  ));
  locator.registerSingleton<DatabaseInterface>(DatabaseInterface(locator<DatabaseInitializer>()));
  locator.registerSingleton<CompoundPoolGenerator>(GraphBasedPoolGenerator(locator<DatabaseInterface>()));

  locator.registerSingleton<LevelProvider>(LogarithmicLevelProvider());

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager());
  locator.registerSingleton<TutorialManager>(TutorialManager(locator<KeyValueStore>()));
  locator.registerSingleton<NotificationManager>(NotificationManager());
  locator.registerSingleton<DailyNotificationScheduler>(
      DailyNotificationScheduler(locator<NotificationManager>(), locator<KeyValueStore>())
  );

}