
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/screens/settings_page.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/numeric_step_button.dart';

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