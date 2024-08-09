import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:kompositum/util/notifications/daily_notification_scheduler.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/widgets/common/util/corner_radius.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../config/locator.dart';
import '../config/my_theme.dart';
import '../util/app_version_provider.dart';
import '../widgets/common/my_app_bar.dart';
import '../widgets/common/my_background.dart';
import '../widgets/common/my_icon_button.dart';
import '../widgets/common/numeric_step_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MaterialApp(
      theme: myTheme,
      home: SettingsPage()
  ));
}

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final keyValueStore = locator<KeyValueStore>();

  bool isDailyNotificationActive = true;

  @override
  void initState() {
    super.initState();
    keyValueStore.getBooleanSetting(BooleanSetting.dailyNotificationsEnabled).then((value) {
      setState(() {
        isDailyNotificationActive = value;
      });
    });
  }

  void setIsDailyNotificationActive(bool newValue) async {
    setState(() {
      isDailyNotificationActive = newValue;
    });
    await keyValueStore.storeBooleanSetting(BooleanSetting.dailyNotificationsEnabled, newValue);
    final dailyNotificationScheduler = locator<DailyNotificationScheduler>();
    dailyNotificationScheduler.tryScheduleNextDailyNotifications(now: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: MyBackground(),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: MyAppBar(
              leftContent: Center(
                child: MyIconButton.centered(
                  icon: MyIcons.navigateBack,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              middleContent: Text(
                "Einstellungen",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              rightContent: Container(),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.0),
                    SettingsGroup(
                      title: "Benachrichtigungen",
                      children: [
                        BooleanSettingsRow(
                          description: "für Tägliche Rätsel",
                          isActive: isDailyNotificationActive,
                          onChange: setIsDailyNotificationActive,
                        )
                      ],
                    ),
                    SizedBox(height: 32.0),
                    SettingsGroup(
                      title: "Datenschutzerklärung",
                      children: [
                        PrivacyPolicy()
                      ],
                    ),
                    SizedBox(height: 32.0),
                    isBuiltWithReleaseMode ? Container() : DevTools()
                  ],
                ),
              ),
            )
        ),
      ],
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final childWidgets = [
      Text(
          title,
          style: Theme.of(context).textTheme.labelLarge
      ),
      SizedBox(height: 16),
    ];
    childWidgets.addAll(children);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CornerRadius.small),
        color: MyColorPalette.of(context).secondary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: childWidgets,
        ),
      ),
    );
  }
}

class BooleanSettingsRow extends StatelessWidget {
  const BooleanSettingsRow({
    required this.description,
    required this.isActive,
    required this.onChange,
  });

  final String description;
  final bool isActive;
  final Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          description,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: MyColorPalette.of(context).textSecondary,
          )
        ),
        Switch(
          value: isActive,
          onChanged: onChange,
        )
      ],
    );
  }
}

class PrivacyPolicy extends StatelessWidget {

  static const String privacyPolicyUrl = "https://github.com/FelberMartin/kompositum/blob/main/PrivacyPolicy.md";

  void _launchPrivacyPolicy() async {
    final Uri url = Uri.parse(privacyPolicyUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $privacyPolicyUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchPrivacyPolicy,
      child: Text(
        "Klicke hier, um unsere Datenschutzerklärung zu lesen (Englisch).",
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: MyColorPalette.of(context).textSecondary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}


class DevTools extends StatelessWidget {
  const DevTools({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
        title: "Dev tools",
        children: [
          MyPrimaryTextButton(
            text: "Send notification (10 sec delay)",
            onPressed: () async {
              final notificationManager = locator<NotificationManager>();
              await notificationManager.scheduleNotification(
                id: 0,
                title: "Test Notification",
                description: "This is a test notification",
                dateTime: DateTime.now().add(Duration(seconds: 10)),
                notificationDetails: NotificationDetails(
                  android: AndroidNotificationDetails(
                    '420',
                    'Test Notification channel',
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          LevelManipulator(),
        ]);
  }
}

class LevelManipulator extends StatefulWidget {
  const LevelManipulator({
    super.key,
  });

  @override
  State<LevelManipulator> createState() => _LevelManipulatorState();
}

class _LevelManipulatorState extends State<LevelManipulator> {
  late KeyValueStore keyValueStore = locator<KeyValueStore>();
  int? level;

  @override
  void initState() {
    super.initState();
    keyValueStore.getLevel().then((value) {
      setState(() {
        level = value;
      });
    });
  }

  void _changeLevel(int value) {
    print('Level changed to $value');
    keyValueStore.storeLevel(value);
    keyValueStore.deleteClassicGameLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Level: ",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(width: 16),
        level == null ? CircularProgressIndicator() : Expanded(
          child: NumericStepButton(
            initialValue: level!,
            minValue: 1,
            maxValue: 1000,
            onChanged: _changeLevel),
        ),
      ],
    );
  }
}