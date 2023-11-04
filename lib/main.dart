
import 'package:flutter/material.dart';
import 'package:kompositum/widgets/home_page.dart';

import 'data/compound_origin.dart';
import 'data/database_initializer.dart';
import 'data/database_interface.dart';
import 'game/level_provider.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', levelProvider: locator<LevelProvider>()),
    );
  }
}


