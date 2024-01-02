import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/screens/game_page_classic.dart';
import 'package:kompositum/util/date_extension.dart';
import 'package:kompositum/widgets/common/my_3d_container.dart';
import 'package:kompositum/widgets/common/my_bottom_navigation_bar.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../config/locator.dart';
import '../config/theme.dart';
import '../data/key_value_store.dart';
import '../game/pool_generator/compound_pool_generator.dart';
import '../game/swappable_detector.dart';
import '../util/color_util.dart';
import '../widgets/common/my_app_bar.dart';
import '../widgets/common/my_background.dart';
import '../widgets/common/my_dialog.dart';
import '../widgets/common/my_icon_button.dart';
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

class _HomePageState extends State<HomePage> {
  late KeyValueStore keyValueStore = locator<KeyValueStore>();

  int starCount = 0;
  int currentLevel = 0;
  Difficulty currentLevelDifficulty = Difficulty.easy;
  bool isDailyFinished = true;

  @override
  void initState() {
    super.initState();

    _updatePage();
    initializeDateFormatting("de", null);
  }

  void _updatePage() {
    keyValueStore.getStarCount().then((value) {
      setState(() {
        starCount = value;
      });
    });

    keyValueStore.getLevel().then((value) {
      setState(() {
        currentLevel = value;
        currentLevelDifficulty = locator<LevelProvider>()
            .generateLevelSetup(currentLevel).displayedDifficulty;
      });
    });

    keyValueStore.getDailiesCompleted().then((value) {
      setState(() {
        isDailyFinished = value.any((day) => day.isSameDate(DateTime.now()));
      });
    });
  }

  void _launchGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(state: GamePageClassicState(
        levelProvider: locator<LevelProvider>(),
        poolGenerator: locator<CompoundPoolGenerator>(),
        keyValueStore: locator<KeyValueStore>(),
        swappableDetector: locator<SwappableDetector>(),
      ),),),
    ).then((value) {
      _updatePage();
    });
  }

  void _launchDailyLevel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(state: GamePageDailyState(
        levelProvider: DailyLevelProvider(),
        poolGenerator: locator<CompoundPoolGenerator>(),
        keyValueStore: locator<KeyValueStore>(),
        swappableDetector: locator<SwappableDetector>(),
        date: DateTime.now(),
      ),),),
    ).then((value) {
      _updatePage();
    });
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
          appBar: MyDefaultAppBar(
            navigationIcon: FontAwesomeIcons.xmark,
            onNavigationPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            starCount: starCount,
          ),
          bottomNavigationBar: MyBottomNavigationBar(
              selectedIndex: 0,
              onReturnToPage: _updatePage,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Container()),
                DailyLevelContainer(
                  isDailyFinished: isDailyFinished,
                  onPlayPressed: _launchDailyLevel,
                ),
                Expanded(flex: 2, child: Container()),
                PlayButton(
                  currentLevel: currentLevel,
                  currentLevelDifficulty: currentLevelDifficulty,
                  onPressed: _launchGame,
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

class DailyLevelContainer extends StatelessWidget {
  const DailyLevelContainer({
    super.key,
    required this.isDailyFinished,
    required this.onPlayPressed,
  });

  final bool isDailyFinished;
  final Function onPlayPressed;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    var dateText = DateFormat("dd. MMM", "de").format(DateTime.now());
    dateText = dateText.substring(0, dateText.length - 1);    // Remove dot
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
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                "Tägliches Rätsel",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 16),
              Icon(
                FontAwesomeIcons.solidCalendarDays,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 32,
              ),
              SizedBox(height: 32),
              Text(
                dateText,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: customColors.textSecondary,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 52,
                width: 120,
                child: Center(
                  child: isDailyFinished
                      ? Icon(
                    FontAwesomeIcons.check,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 32,
                  )
                      : MySecondaryTextButton(
                    text: "Start",
                    onPressed: onPlayPressed,
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
  });

  final int currentLevel;
  final Difficulty currentLevelDifficulty;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return My3dContainer(
      topColor: Theme.of(context).colorScheme.primary,
      sideColor: darken(Theme.of(context).colorScheme.primary),
      clickable: true,
      onPressed: onPressed,
      child: SizedBox(
        width: 260,
        height: 80,
        child: Column(
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