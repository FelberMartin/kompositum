
import 'package:flutter/material.dart';
import 'package:kompositum/widgets/home_page.dart';

import 'compound_pool_generator.dart';
import 'data/compound_origin.dart';
import 'data/database_initializer.dart';
import 'data/database_interface.dart';
import 'level_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("Initializing database");
    final databaseInitializer = DatabaseInitializer(CompoundOrigin("assets/filtered_compounds.csv"));
    final databaseInterface = DatabaseInterface(databaseInitializer);
    final compoundPoolGenerator = CompoundPoolGenerator(databaseInterface);
    final levelProvider = BasicLevelProvider(compoundPoolGenerator);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', levelProvider: levelProvider,),
    );
  }
}


