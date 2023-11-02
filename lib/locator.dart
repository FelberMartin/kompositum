import 'package:get_it/get_it.dart';

import 'compound_pool_generator.dart';
import 'data/compound_origin.dart';
import 'data/database_initializer.dart';
import 'data/database_interface.dart';
import 'level_provider.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<CompoundOrigin>(CompoundOrigin("assets/filtered_compounds.json"));
  locator.registerSingleton<DatabaseInitializer>(DatabaseInitializer(locator<CompoundOrigin>()));
  locator.registerSingleton<DatabaseInterface>(DatabaseInterface(locator<DatabaseInitializer>()));
  locator.registerSingleton<CompoundPoolGenerator>(CompoundPoolGenerator(locator<DatabaseInterface>()));
  locator.registerSingleton<LevelProvider>(BasicLevelProvider(locator<CompoundPoolGenerator>()));
}