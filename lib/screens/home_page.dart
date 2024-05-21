import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/screens/game_page_classic.dart';
import 'package:kompositum/screens/settings_page.dart';
import 'package:kompositum/util/app_lifecycle_reactor.dart';
import 'package:kompositum/util/date_util.dart';
import 'package:kompositum/util/notifications/notifictaion_manager.dart';
import 'package:kompositum/widgets/common/my_3d_container.dart';
import 'package:kompositum/widgets/common/my_bottom_navigation_bar.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_icon_button.dart';
import 'package:kompositum/widgets/home/daily_goals_container.dart';

import '../config/locator.dart';
import '../config/my_icons.dart';
import '../config/my_theme.dart';
import '../data/key_value_store.dart';
import '../game/goals/daily_goal_set_manager.dart';
import '../widgets/common/my_background.dart';
import '../widgets/common/util/clip_shadow_path.dart';
import '../widgets/common/util/rounded_edge_clipper.dart';
import 'game_page.dart';
import 'game_page_daily.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MaterialApp(
      theme: myTheme,
      home: HomePage()
  ));
}


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late KeyValueStore keyValueStore = locator<KeyValueStore>();
  late NotificationManager notificationManager = locator<NotificationManager>();
  late DailyGoalSetManager dailyGoalSetManager = locator<DailyGoalSetManager>();

  int starCount = 0;
  int currentLevel = 0;
  Difficulty currentLevelDifficulty = Difficulty.easy;
  bool isDailyFinished = true;
  late DailyGoalSetProgression dailyGoalSetProgression;

  bool isLoading = true;

  // Note: Only one instance of AppLifecycleReactor is needed. No need to
  // add one in another app screen.
  final AppLifecycleReactor _appLifecycleReactor = AppLifecycleReactor();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(_appLifecycleReactor);

    _updatePage();
    initializeDateFormatting("de", null);

    keyValueStore.isFirstLaunch().then((value) {
      if (value) {
        _launchGame(GameMode.Pool);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_appLifecycleReactor);
    super.dispose();
  }

  void _updatePage() async {
    setState(() {
      isLoading = true;
    });

    starCount = await keyValueStore.getStarCount();
    currentLevel = await keyValueStore.getLevel();
    currentLevelDifficulty = locator<LevelProvider>()
        .generateLevelSetup(currentLevel).displayedDifficulty;
    isDailyFinished = await keyValueStore.getDailiesCompleted()
        .then((value) => value.any((day) => day.isSameDate(DateTime.now())));
    dailyGoalSetProgression = await dailyGoalSetManager.getProgression();
    dailyGoalSetManager.resetProgression();

    setState(() {
      isLoading = false;
    });
  }

  void _launchGame(GameMode gameMode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(state: GamePageClassicState.fromLocator(gameMode))),
    ).then((value) {
      _updatePage();
    });
  }

  void _launchDailyLevel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(
        state: GamePageDailyState.fromLocator(DateTime.now()))),
    ).then((value) {
      _updatePage();
    });
  }

  void _launchSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    ).then((value) {
      _updatePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final shouldShowDailyGoals = height > 680;
    return Stack(
      children: [
        const Positioned.fill(
          child: MyBackground(),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: MyBottomNavigationBar(
              selectedIndex: 0,
              onReturnToPage: _updatePage,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SettingsRow(onPressed: _launchSettings),
                isLoading ? DailyLevelContainer.loading() : DailyLevelContainer(
                  isDailyFinished: isDailyFinished,
                  onPlayPressed: _launchDailyLevel,
                ),
                Expanded(flex: 1, child: Container()),
                isLoading || !shouldShowDailyGoals ? Container() : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: DailyGoalsContainer(
                    key: ValueKey(dailyGoalSetProgression.current.progress),
                    progression: dailyGoalSetProgression,
                    animationStartDelay: Duration.zero,
                    onPlaySecretLevel: () {}, // TODO
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                isLoading ? PlayButton.loading() : PlayButton(
                  currentLevel: currentLevel,
                  currentLevelDifficulty: currentLevelDifficulty,
                  onPressed: () => _launchGame(GameMode.Pool),
                ),
                Expanded(child: Container()),
              ],
            ),
          )
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {

  const SettingsRow({
    required this.onPressed
  });

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MyIconButton(
                icon: MyIcons.settings,
                onPressed: onPressed,
            )
          ],
        ),
      ),
    );
  }
}

class DailyLevelContainer extends StatelessWidget {
  const DailyLevelContainer({
    super.key,
    required this.isDailyFinished,
    required this.onPlayPressed,
  });

  final bool? isDailyFinished;
  final Function onPlayPressed;

  factory DailyLevelContainer.loading() {
    return DailyLevelContainer(
      isDailyFinished: null,
      onPlayPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    var dateText = DateFormat("dd. MMM", "de").format(DateTime.now());
    return ClipShadowPath(
      clipper: RoundedEdgeClipper(edgeCutDepth: 24),
      shadow: Shadow(
        color: Theme.of(context).colorScheme.shadow.withOpacity(0.4),
        offset: Offset(0, 2),
        blurRadius: 2,
      ),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 200,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MyColorPalette.of(context).secondaryShade,
              MyColorPalette.of(context).secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Text(
                "Tägliches Rätsel",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 12),
              Icon(
                MyIcons.daily,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 32,
              ),
              SizedBox(height: 28),
              Text(
                dateText,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: MyColorPalette.of(context).textSecondary,
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 52,
                width: 120,
                child: Center(
                  child: isDailyFinished == null
                      ? Center(child: CircularProgressIndicator(
                          color: MyColorPalette.of(context).textSecondary))
                      : isDailyFinished!
                      ? Icon(
                        MyIcons.check,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 32,
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MySecondaryTextButton(
                            key: Key("daily_play_button"),
                            text: "Start",
                            onPressed: onPlayPressed,
                          ),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.currentLevel,
    required this.currentLevelDifficulty,
    required this.onPressed,
    this.isLoading = false,
  });

  final int currentLevel;
  final Difficulty currentLevelDifficulty;
  final bool isLoading;
  final Function onPressed;

  factory PlayButton.loading() {
    return PlayButton(
      currentLevel: 0,
      currentLevelDifficulty: Difficulty.easy,
      onPressed: () {},
      isLoading: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.primary,
      sideColor: MyColorPalette.of(context).primaryShade,
      clickable: true,
      onPressed: onPressed,
      child: SizedBox(
        width: 260,
        height: 80,
        child: isLoading ? Center(
            child: CircularProgressIndicator(
                color: MyColorPalette.of(context).textSecondary)) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Level $currentLevel",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 4.0),
            Text(
              currentLevelDifficulty.toUiString(),
              style: Theme.of(context).textTheme.labelSmall,
            )
          ],
        ),
      )
    );
  }
}