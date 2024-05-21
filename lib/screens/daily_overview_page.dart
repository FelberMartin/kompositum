import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/screens/game_page_daily.dart';
import 'package:kompositum/util/date_util.dart';
import 'package:kompositum/util/emoji_provider.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';
import 'package:kompositum/widgets/common/my_icon_button.dart';
import 'package:table_calendar/table_calendar.dart';

import '../config/locator.dart';
import '../config/my_theme.dart';
import '../config/star_costs_rewards.dart';
import '../data/key_value_store.dart';
import '../util/ads/ad_manager.dart';
import '../widgets/common/my_app_bar.dart';
import '../widgets/common/my_background.dart';
import '../widgets/common/my_bottom_navigation_bar.dart';
import '../widgets/daily_overview/dialogs/play_past_daily_dialog.dart';
import 'game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MaterialApp(
      theme: myTheme,
      home: DailyOverviewPage()
  ));
}


class DailyOverviewPage extends StatefulWidget {
  @override
  State<DailyOverviewPage> createState() => _DailyOverviewPageState();
}

class _DailyOverviewPageState extends State<DailyOverviewPage> {
  late KeyValueStore keyValueStore = locator<KeyValueStore>();
  late AdManager adManager = locator<AdManager>();

  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  int starCount = 0;
  List<DateTime> completedDays = [];

  @override
  void initState() {
    super.initState();
    _updatePage();
    initializeDateFormatting('de_DE', null);
  }

  void _updatePage() async {
    starCount = await keyValueStore.getStarCount();
    completedDays = await keyValueStore.getDailiesCompleted();
    _updateSelectedDay();
  }

  void _updateSelectedDay() {
    _selectedDay = findNextDateInMonthNotInList(
      maxDate: DateTime.now(),
      excludeList: completedDays,
      inMonth: _focusedDay,
    );
    setState(() {});
  }

  void _onPlayPressed() {
    if (_selectedDay == null) {
      return;
    }
    if (_selectedDay!.isSameDate(DateTime.now())) {
      _launchGame();
      return;
    }
    _openPlayPastDailyDialog();
  }

  void _openPlayPastDailyDialog() {
    animateDialog(context: context, dialog: PlayPastDailyDialog(
      hasEnoughStars: starCount >= Costs.pastDailyCost,
    )).then((result) {
      if (result == null) {
        return;
      }
      if (result == PlayPastDailyDialogResult.playWithStars) {
        keyValueStore.increaseStarCount(-Costs.pastDailyCost);
        _launchGame();
      }
      if (result == PlayPastDailyDialogResult.playWithAd) {
        adManager.showAd(context).then((value) {
          _launchGame();
        });
      }
    });
  }

  void _launchGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(
          state: GamePageDailyState.fromLocator(_selectedDay!))
    )).then((value) {
      _updatePage();
    });
  }

  bool _isMonthCompleted() {
    return containsAllDaysInMonth(
      month: _focusedDay,
      days: completedDays,
    );
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
              onNavigationPressed: () {
                Navigator.pop(context);
              },
              middleContent: Text(
                "Tägliche Rätsel",
                style: Theme
                    .of(context)
                    .textTheme
                    .titleSmall,
              ),
              starCount: starCount,
            ),
            bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: 1),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Container()),
                    MonthCompletionReward(
                      month: _focusedDay,
                      isCompleted: _isMonthCompleted(),
                    ),
                    Expanded(child: Container()),
                    Calendar(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      setSelectedDay: (day) {
                        setState(() { _selectedDay = day; });
                      },
                      setFocusDay: (day) {
                        _focusedDay = day;
                        _updateSelectedDay();
                      },
                      completedDays: completedDays,
                    ),
                    Expanded(child: Container()),
                    MyPrimaryTextButtonLarge(
                      text: "Start",
                      enabled: isPlayEnabled(),
                      onPressed: () {
                        _onPlayPressed();
                      },
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            )
        ),
      ],
    );
  }

  bool isPlayEnabled() {
    if (_selectedDay == null) {
      return false;
    }
    if (completedDays.any((datetime) => datetime.isSameDate(_selectedDay!))) {
      return false;
    }
    if (_selectedDay!.isAfter(DateTime.now())) {
      return false;
    }
    return true;
  }
}

class MonthCompletionReward extends StatelessWidget {
  const MonthCompletionReward({
    required this.month,
    required this.isCompleted,
    super.key,
  });

  final DateTime month;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fontSize = height / 8;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: isCompleted
        ? Stack(
          key: ValueKey(month.month),
          alignment: Alignment.center,
          children: [
            Container(
              width: fontSize * 1.5,
              height: fontSize * 1.5,
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.colorDodge,
                gradient: RadialGradient(
                  colors: [
                    Colors.white, Colors.transparent,
                  ]
                )
              )
            ),
            Text(
                EmojiProvider.instance.getEmojiForDailyMonthCompletion(month),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: fontSize,
                    fontFamily: "NotoEmoji"
                )
            ),
          ],
        )
        : Text(
            key: ValueKey("incomplete"),
            "?",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontSize: fontSize,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            )
        )
    );
  }
}

class Calendar extends StatelessWidget {

  const Calendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.setSelectedDay,
    required this.setFocusDay,
    required this.completedDays,
    super.key,
  });

  final DateTime? selectedDay;
  final DateTime focusedDay;
  final Function(DateTime) setSelectedDay;
  final Function(DateTime) setFocusDay;
  final List<DateTime> completedDays;

  bool isCompleted(DateTime date) {
    return completedDays.any((datetime) => datetime.isSameDate(date));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.now(),
      currentDay: DateTime.now(),
      locale: "de_DE",
      rowHeight: height > 650 ? 48 : 32,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        leftChevronIcon: MyIconButton(
          icon: FontAwesomeIcons.chevronLeft,
          onPressed: () {},
        ),
        leftChevronPadding: const EdgeInsets.all(0),
        leftChevronMargin: const EdgeInsets.symmetric(horizontal: 16.0),
        rightChevronIcon: MyIconButton(
          icon: FontAwesomeIcons.chevronRight,
          onPressed: () {},
        ),
        rightChevronPadding: const EdgeInsets.all(0),
        rightChevronMargin: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: (_selectedDay, _focusedDay) {
        if (!isCompleted(_selectedDay)) {
          setSelectedDay(_selectedDay);
        }
      },
      onPageChanged: (focusedDay) {
        setFocusDay(focusedDay);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          return DayContainer(
            date: date,
            isSelected: selectedDay == date,
            isInMonth: true,
            isCompleted: isCompleted(date),
          );
        },
        disabledBuilder: (context, date, _) {
          return DayContainer(
            date: date,
            isSelected: selectedDay == date,
            isInMonth: false,
            isCompleted: isCompleted(date),
          );
        },
        selectedBuilder: (context, date, _) {
          return DayContainer(
            date: date,
            isSelected: true,
            isInMonth: true,
            isCompleted: isCompleted(date),
          );
        },
        todayBuilder: (context, date, _) {
          return DayContainer(
            date: date,
            isSelected: selectedDay == date,
            isInMonth: true,
            isCompleted: isCompleted(date),
          );
        },
      ),
    );
  }


}


class DayContainer extends StatelessWidget {
  const DayContainer({
    required this.date,
    required this.isSelected,
    required this.isInMonth,
    required this.isCompleted,
    super.key,
  });

  final DateTime date;
  final bool isSelected;
  final bool isInMonth;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    Gradient? gradient;
    if (isCompleted) {
      gradient = LinearGradient(
        colors: [
          MyColorPalette.of(context).secondaryShade,
          MyColorPalette.of(context).secondary,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    if (isSelected) {
      gradient = LinearGradient(
        colors: [
          MyColorPalette.of(context).primaryShade,
          MyColorPalette.of(context).primary,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    return Opacity(
      opacity: isInMonth ? 1.0 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.0,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        margin: const EdgeInsets.all(4.0),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: isCompleted
                ? Icon(
              MyIcons.check,
              color: MyColorPalette.of(context).onSecondary,
              size: 16.0,
            )
                : Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.labelMedium!,
            ),
          )
        ),
      ),
    );
  }
}

