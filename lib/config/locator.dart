import 'package:get_it/get_it.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';


import '../data/compound_origin.dart';
import '../data/database_initializer.dart';
import '../data/database_interface.dart';
import '../data/key_value_store.dart';
import '../game/level_provider.dart';
import '../game/pool_generator/compound_pool_generator.dart';

final locator = GetIt.instance;

Future<void> setupLocator({env = "prod"}) async {
  locator.registerSingleton<CompoundOrigin>(CompoundOrigin("assets/filtered_compounds.csv"));

  final docsDir = await getApplicationDocumentsDirectory();
  final reset = env == "test" ? true : false;

  locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(
      compoundOrigin: locator<CompoundOrigin>(),
      path: docsDir.path,
      reset: reset
  ));
  locator.registerSingleton<DatabaseInterface>(DatabaseInterface(locator<DatabaseInitializer>()));
  locator.registerSingleton<KeyValueStore>(KeyValueStore());
  locator.registerSingleton<CompoundPoolGenerator>(GraphBasedPoolGenerator(locator<DatabaseInterface>()));
  locator.registerSingleton<LevelProvider>(LogarithmicLevelProvider());
  // SharedPreferences.setMockInitialValues({"level": 1});

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager());
}