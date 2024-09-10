import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kompositum/config/flavors/flavor.dart';
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
import '../widgets/settings/dev_tools.dart';

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
                Flavor.instance.uiString.ttlSettings,
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
                      title: Flavor.instance.uiString.ttlNotifications,
                      children: [
                        BooleanSettingsRow(
                          description: Flavor.instance.uiString.lblNotificationForDailies,
                          isActive: isDailyNotificationActive,
                          onChange: setIsDailyNotificationActive,
                        )
                      ],
                    ),
                    SizedBox(height: 32.0),
                    SettingsGroup(
                      title: Flavor.instance.uiString.ttlPrivacyPolicy,
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
        Flavor.instance.uiString.lblClickForPrivacyPolicy,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: MyColorPalette.of(context).textSecondary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}