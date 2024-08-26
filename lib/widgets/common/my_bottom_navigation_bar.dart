import 'package:flutter/material.dart';
import 'package:kompositum/screens/daily_overview_page.dart';
import 'package:kompositum/widgets/common/util/corner_radius.dart';
import 'package:kompositum/widgets/common/util/rounded_edge_clipper.dart';

import '../../config/my_icons.dart';
import '../../config/my_theme.dart';


class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({
    required this.selectedIndex,
    this.onReturnToPage,
    super.key,
  });


  final int selectedIndex;
  final Function? onReturnToPage;

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {

  final items = const [
    BottomNavigationBarItem(
      icon: Icon(
          key: Key("tabBarHome"),
          MyIcons.home
      ),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(
          key: Key("tabBarDaily"),
          MyIcons.daily),
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
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => DailyOverviewPage())
      ).then((value) => widget.onReturnToPage?.call());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CornerRadius.large),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          items: items,
          onTap: (index) {
            onItemSelected(index);
          },
          currentIndex: widget.selectedIndex,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor: Theme.of(context).colorScheme.onSecondary,
          unselectedItemColor: MyColorPalette.of(context).textSecondary,
          showUnselectedLabels: false,
          showSelectedLabels: false,
        ),
      ),
    );
  }
}