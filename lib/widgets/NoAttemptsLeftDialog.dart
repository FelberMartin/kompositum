import 'package:flutter/material.dart';
import 'package:kompositum/util/clip_shadow_path.dart';
import 'package:kompositum/util/rounded_edge_clipper.dart';

import '../theme.dart';

// Preview the dialog:
void main() =>
    runApp(MaterialApp(theme: myTheme, home: NoAttemptsLeftDialog()));

class MyDialog extends StatelessWidget {
  const MyDialog({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipPath(
        clipper: RoundedEdgeClipper(edgeCutDepth: 30),
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 32),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoAttemptsLeftDialog extends StatelessWidget {
  const NoAttemptsLeftDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyDialog(
      title: "Du hast alle Versuche aufgebraucht!",
      child: Column(
        children: [
          Text(
            "Du kannst entweder ein neues Level starten oder ein paar Minuten warten, bis sich deine Versuche wieder aufgefüllt haben.",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text("Neues Level"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("Warten"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
