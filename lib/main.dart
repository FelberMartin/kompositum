import 'package:flutter/material.dart';
import 'package:kompositum/config/theme.dart';
import 'package:kompositum/screens/game_page.dart';

import 'config/locator.dart';
import 'data/key_value_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'game/level_provider.dart';
import 'game/pool_generator/compound_pool_generator.dart';
import 'game/swappable_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
