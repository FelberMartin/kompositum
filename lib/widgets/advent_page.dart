import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data/key_value_store.dart';
import '../game/advent_day.dart';
import '../locator.dart';
import 'game_page.dart';

class AdventPage extends StatefulWidget {
  const AdventPage({Key? key}) : super(key: key);

  @override
  State<AdventPage> createState() => _AdventPageState();
}

class _AdventPageState extends State<AdventPage> {

  final keyValStore = locator<KeyValueStore>();

  final List<int> shuffledNumbers = List.generate(24, (index) => index + 1)..shuffle(Random(1));
  late int todayNumber;
  late List<bool> isDayOpened;
  late List<bool> isDayCompleted;
  bool isLoading = true;

  late List<AdventDay> adventDays;

  _AdventPageState() {
    var beforeDecember2023 = DateTime.now().month < DateTime.december && DateTime.now().year == 2023;
    var duringDecember2023 = DateTime.now().month == DateTime.december && DateTime.now().year == 2023;
    beforeDecember2023 = false;
    duringDecember2023 = true; // TODO: remove this
    if (beforeDecember2023) {
      todayNumber = 0;
    } else if (duringDecember2023) {
      todayNumber = DateTime.now().day;
    } else {
      todayNumber = 25; // Show all contents
    }

    load();
  }

  Future<void> load() async {
    final assetData = await rootBundle.loadString("assets/advent.json");
    final jsonData = jsonDecode(assetData) as List<dynamic>;
    adventDays = jsonData.map((e) => AdventDay.fromJson(e)).toList();
    print("Loaded ${adventDays.length} advent days");

    isDayOpened = await keyValStore.getAdventOpened();
    isDayCompleted = await keyValStore.getAdventCompleted();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> reload() async {
    isDayCompleted = await keyValStore.getAdventCompleted();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isLoading ? const CircularProgressIndicator() : InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.1,
          maxScale: 3.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
              // Add a grid layout with 4 columns and 6 rows.
              // Each element in the grid should be a container with a border
              // and a number in the middle.
              // The number should be the index of the element in the grid.
              // The grid should be centered in the middle of the screen.
              Positioned.fill(child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(10),
                children: List.generate(24, (index) {
                  final number = shuffledNumbers[index];
                  final dayIndex = number - 1;
                  return Tile(
                    number: number,
                    visible: number <= todayNumber,
                    isOpen: isDayOpened[dayIndex],
                    isCompleted: isDayCompleted[dayIndex],
                    finishedBackground: "assets/finished/$number.jpg",
                    onSetOpen: (open) {
                      setState(() {
                        isDayOpened[dayIndex] = open;
                      });
                      keyValStore.storeAdventOpened(isDayOpened);
                    },
                    onPlayLevel: () {
                      final day = adventDays[dayIndex];
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GamePage(adventDay: day)
                        ),
                      ).then((value) {
                        reload();
                      });
                      print("Play level $number");
                    },
                  );
                }),
              ),
              ),
          ]),
        ),
      ));
  }
}

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.number,
    required this.visible,
    required this.isOpen,
    required this.isCompleted,
    required this.finishedBackground,
    required this.onSetOpen,
    required this.onPlayLevel,
  });

  final int number;
  final bool visible;
  final bool isOpen;
  final bool isCompleted;
  final String finishedBackground;
  final Function(bool) onSetOpen;
  final Function onPlayLevel;

  final _color = const Color(0xFFB2C5DA);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (visible) {
          onSetOpen(!isOpen);
        }
      },
      onLongPress: () {
        if (visible && isOpen && isCompleted) {
          onPlayLevel();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _color),
          borderRadius: BorderRadius.circular(4),
          color: isOpen ? Color(0xFFB2C5DA) : Colors.transparent,
        ),
        padding: EdgeInsets.only(left:3),
        child: _containerContent(context),
      ),
    );
  }

  Widget _containerContent(context) {
    if (!isOpen) {
      return Text(
        "${visible ? number : "?"}",
        style: TextStyle(color: _color)
      );
    }
    if (!isCompleted) {
      return Center(
        child: IconButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => onPlayLevel(),
          icon: const Icon(Icons.play_arrow),
        )
      );
    }

    return Icon(Icons.check, color: Theme.of(context).colorScheme.primary);
    // return Image(
    //   image: AssetImage(finishedBackground),
    //   fit: BoxFit.cover,
    // );
  }
}
