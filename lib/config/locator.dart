import 'package:get_it/get_it.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/compound_origin.dart';
import '../data/database_initializer.dart';
import '../data/database_interface.dart';
import '../data/key_value_store.dart';
import '../game/level_provider.dart';
import '../game/pool_generator/compound_pool_generator.dart';

final locator = GetIt.instance;

void setupLocator({env = "test"}) {
  locator.registerSingleton<CompoundOrigin>(CompoundOrigin("assets/filtered_compounds.csv"));
  if (env == "prod") {
    locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(locator<CompoundOrigin>(), reset: false));
  } else {
    locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(locator<CompoundOrigin>(), reset: true, useInMemoryDatabase: true));
  }
  locator.registerSingleton<DatabaseInterface>(DatabaseInterface(locator<DatabaseInitializer>()));
  locator.registerSingleton<KeyValueStore>(KeyValueStore());
  locator.registerSingleton<CompoundPoolGenerator>(GraphBasedPoolGenerator(locator<DatabaseInterface>()));
  locator.registerSingleton<LevelProvider>(LogarithmicLevelProvider());
  SharedPreferences.setMockInitialValues({"level": 1});

  locator.registerSingleton<SwappableDetector>(SwappableDetector(locator<DatabaseInterface>()));
  locator.registerSingleton<AdManager>(AdManager());
}