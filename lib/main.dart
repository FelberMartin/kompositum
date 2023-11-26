import 'package:flutter/material.dart';
import 'package:kompositum/theme.dart';
import 'package:kompositum/widgets/game_page.dart';

import 'data/key_value_store.dart';
import 'game/level_provider.dart';
import 'game/pool_generator/compound_pool_generator.dart';
import 'game/swappable_detector.dart';
import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: myTheme,
      home: GamePage(
          title: 'Komposita: Wörter zusammensetzen',
          levelProvider: locator<LevelProvider>(),
          poolGenerator: locator<CompoundPoolGenerator>(),
          keyValueStore: locator<KeyValueStore>(),
          swappableDetector: locator<SwappableDetector>(),
      ),
    );
  }
}
