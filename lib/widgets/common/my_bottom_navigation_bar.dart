import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/screens/daily_overview_page.dart';
import 'package:kompositum/widgets/common/util/rounded_edge_clipper.dart';

import '../../config/theme.dart';
import '../../screens/home_page.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({
    required this.selectedIndex,
    super.key,
  });

  final int selectedIndex;

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {

  final items = const [
    BottomNavigationBarItem(
      icon: Icon(FontAwesomeIcons.house),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(FontAwesomeIcons.solidCalendarDays),
      label: "Daily",
    ),
  ];

  void onItemSelected(int index) {
    if (index == widget.selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DailyOverviewPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return ClipPath(
      clipper: RoundedEdgeClipper(onBottom: false),
      child: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          items: items,
          onTap: (index) {
            onItemSelected(index);
          },
          currentIndex: widget.selectedIndex,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor: Theme.of(context).colorScheme.onSecondary,
          unselectedItemColor: customColors.textSecondary,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          elevation: 0,
        ),
      ),
    );
  }
}