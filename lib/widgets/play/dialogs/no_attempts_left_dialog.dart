import 'package:flutter/material.dart';
import 'package:kompositum/util/clip_shadow_path.dart';
import 'package:kompositum/util/rounded_edge_clipper.dart';

import '../../../config/theme.dart';
import '../../common/my_dialog.dart';

// Preview the dialog:
void main() =>
    runApp(MaterialApp(theme: myTheme, home: NoAttemptsLeftDialog()));

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
