import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_icon_button.dart';
import 'package:table_calendar/table_calendar.dart';

import '../config/locator.dart';
import '../config/theme.dart';
import '../data/key_value_store.dart';
import '../widgets/common/my_app_bar.dart';
import '../widgets/common/my_background.dart';
import '../widgets/common/my_bottom_navigation_bar.dart';

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

  int starCount = 0;
  DateTime _selectedDay = DateTime.now();
  List<DateTime> completedDays = [
    DateTime.utc(2023, 12, 1),
    DateTime.utc(2023, 12, 2),
    DateTime.utc(2023, 12, 5),
    DateTime.utc(2023, 12, 6),
    DateTime.utc(2023, 12, 22),
  ];

  @override
  void initState() {
    super.initState();
    keyValueStore.getStarCount().then((value) {
      setState(() {
        starCount = value;
      });
    });

    initializeDateFormatting('de_DE', null);
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
              navigationIcon: FontAwesomeIcons.chevronLeft,
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 2, child: Container()),
                    TableCalendar(
                      focusedDay: _selectedDay,
                      firstDay: DateTime.utc(2023, 12, 1),
                      lastDay: DateTime.utc(2050, 12, 31),
                      currentDay: DateTime.now(),
                      locale: "de_DE",
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
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                        });
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, _) {
                          return DayContainer(
                            date: date,
                            isSelected: _selectedDay == date,
                            isToday: isSameDay(DateTime.now(), date),
                            isInMonth: true,
                            isCompleted: completedDays.contains(date),
                          );
                        },
                        disabledBuilder: (context, date, _) {
                          return DayContainer(
                            date: date,
                            isSelected: _selectedDay == date,
                            isToday: isSameDay(DateTime.now(), date),
                            isInMonth: false,
                            isCompleted: completedDays.contains(date),
                          );
                        },
                        selectedBuilder: (context, date, _) {
                          return DayContainer(
                            date: date,
                            isSelected: true,
                            isToday: isSameDay(DateTime.now(), date),
                            isInMonth: true,
                            isCompleted: completedDays.contains(date),
                          );
                        },
                        todayBuilder: (context, date, _) {
                          return DayContainer(
                            date: date,
                            isSelected: _selectedDay == date,
                            isToday: true,
                            isInMonth: true,
                            isCompleted: completedDays.contains(date),
                          );
                        },
                      ),
                    ),
                    Expanded(child: Container()),
                    MyPrimaryTextButtonLarge(
                      text: "Start",
                      enabled: !completedDays.contains(_selectedDay) && _selectedDay.isBefore(DateTime.now()),
                      onPressed: () {
                        // TODO
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
}


class DayContainer extends StatelessWidget {
  const DayContainer({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isInMonth,
    required this.isCompleted,
    super.key,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isInMonth;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    var color = Colors.transparent;
    if (isCompleted) {
      color = Theme.of(context).colorScheme.secondary;
    }
    if (isSelected) {
      color = Theme.of(context).colorScheme.primary;
    }
    print("date $date, isToday $isToday, isInMonth $isInMonth, isSelected $isSelected, isCompleted $isCompleted");
    return Opacity(
      opacity: isInMonth ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isToday ? Colors.white : Colors.transparent,
            width: 2.0,
          ),
        ),
        margin: const EdgeInsets.all(4.0),
        child: Center(
          child: Text(
            date.day.toString(),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

