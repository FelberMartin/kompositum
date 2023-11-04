import 'package:get_it/get_it.dart';

import 'compound_pool_generator.dart';
import 'data/compound_origin.dart';
import 'data/database_initializer.dart';
import 'data/database_interface.dart';
import 'level_provider.dart';

final locator = GetIt.instance;

void setupLocator({env = "prod"}) {
  locator.registerSingleton<CompoundOrigin>(CompoundOrigin("assets/filtered_compounds.csv"));
  if (env == "prod") {
    locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(locator<CompoundOrigin>(), reset: false));
  } else {
    locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(locator<CompoundOrigin>(), reset: true, useInMemoryDatabase: true));
  }
  locator.registerSingleton<DatabaseInterface>(DatabaseInterface(locator<DatabaseInitializer>()));
  locator.registerSingleton<CompoundPoolGenerator>(NoConflictCompoundPoolGenerator(locator<DatabaseInterface>()));
  locator.registerSingleton<LevelProvider>(BasicLevelProvider(locator<CompoundPoolGenerator>()));
}