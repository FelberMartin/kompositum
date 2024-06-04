import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/screens/home_page.dart';
import 'package:kompositum/util/audio_manager.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';

import 'config/locator.dart';
import 'data/database_interface.dart';
import 'data/key_value_store.dart';
import 'data/remote/firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  unawaited(MobileAds.instance.initialize());

  await setupLocator();
  initNotifications();
  _initAudioManager();
  _initAndRemoveSplashScreen();
  runApp(const MyApp());
}

void initNotifications() {
  final dailyScheduler = locator<DailyNotificationScheduler>();
  dailyScheduler.tryScheduleNextDailyNotification(now: DateTime.now());
}

void _initAudioManager() {
  AudioManager.instance.registerKeyValueStore(locator<KeyValueStore>());
}

void _initAndRemoveSplashScreen() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  sendPendingDataToFirestore();
  await locator<DatabaseInterface>().waitForInitialization();
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Wortschatz',
      theme: myTheme,
      locale: const Locale('de', 'DE'),
      home: HomePage(),
    );
  }
}
