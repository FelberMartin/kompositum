import 'package:get_it/get_it.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/classic_level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/generator/compound_pool_generator.dart';
import 'package:kompositum/game/modi/classic/generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/util/device_info.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:path_provider/path_provider.dart';


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

  locator.registerSingleton<LevelSetupProvider>(LogarithmicLevelSetupProvider());

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager());
  locator.registerSingleton<TutorialManager>(TutorialManager(locator<KeyValueStore>()));
  locator.registerSingleton<NotificationManager>(NotificationManager());
  locator.registerSingleton<DailyNotificationScheduler>(
      DailyNotificationScheduler(locator<NotificationManager>(), locator<KeyValueStore>())
  );

  locator.registerSingleton<DeviceInfo>(DeviceInfo());
  locator.registerSingleton<DailyGoalSetManager>(DailyGoalSetManager(locator<KeyValueStore>(), locator<DeviceInfo>()));

}