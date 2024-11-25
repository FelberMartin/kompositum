import 'package:get_it/get_it.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/game_event/game_event_stream.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/modi/chain/generator/chain_generator.dart';
import 'package:kompositum/game/modi/classic/classic_level_setup_provider.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/classic/generator/graph_based_classic_level_content_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/ads/ad_mod/ad_mob_ad_source.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:kompositum/util/device_info.dart';
import 'package:kompositum/util/feature_lock_manager.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:kompositum/util/update_manager.dart';
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
  locator.registerSingleton<LevelContentGenerator>(GraphBasedClassicLevelContentGenerator(locator<DatabaseInterface>()));

  locator.registerSingleton<LevelSetupProvider>(LogarithmicLevelSetupProvider());

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager(
    restartLevelAdSource: AdMobAdSource.fromAdContext(AdContext.restartLevel),
    playPastDailyChallengeAdSource: AdMobAdSource.fromAdContext(AdContext.playPastDailyChallenge),
  ));
  locator.registerSingleton<TutorialManager>(TutorialManager(locator<KeyValueStore>()));
  locator.registerSingleton<FeatureLockManager>(FeatureLockManager(
    gameEventStream: GameEventStream.instance.stream,
    keyValueStore: locator<KeyValueStore>(),
  ));

  locator.registerSingleton<NotificationManager>(NotificationManager());
  locator.registerSingleton<DailyNotificationScheduler>(DailyNotificationScheduler(
      notificationManager: locator<NotificationManager>(),
      keyValueStore: locator<KeyValueStore>(),
      featureLockManager: locator<FeatureLockManager>(),
  ));
  locator.registerSingleton<UpdateManager>(UpdateManager(
      appVersionProvider: locator<AppVersionProvider>(),
      keyValueStore: locator<KeyValueStore>(),
  ));

  locator.registerSingleton<DeviceInfo>(DeviceInfo());
  locator.registerSingleton<DailyGoalSetManager>(DailyGoalSetManager(
      keyValueStore: locator<KeyValueStore>(),
      deviceInfo: locator<DeviceInfo>(),
      featureLockManager: locator<FeatureLockManager>(),
  ));

  locator.registerSingleton<ChainGenerator>(ChainGenerator(locator<DatabaseInterface>()));

}