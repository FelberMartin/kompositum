import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';
import 'package:kompositum/widgets/play/combination_area.dart';

import '../../../config/theme.dart';

void main() => runApp(MaterialApp(
    theme: myTheme,
    home: ReportDialog(
      modifier: "Baum",
      head: "Schuh",
      onClose: () {},
    )));

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.modifier,
    required this.head,
    required this.onClose,
  });

  final String modifier;
  final String head;
  final Function onClose;

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {

  String compoundText = "";

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyDialog(
        title: "Du hast ein fehlendes Wort gefunden?",
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MySecondaryTextButton(
                  onPressed: () {},
                  text: widget.modifier,
                ),
                SizedBox(width: 8),
                IconStyledText(text: "+", strokeWidth: 2),
                SizedBox(width: 8),
                MySecondaryTextButton(
                  onPressed: () {},
                  text: widget.head,
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                IconStyledText(text: "="),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Wort eingeben",
                      hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: customColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: customColors.textSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                    ),
                    onChanged: (value) {
                      setState(() {
                        compoundText = value.trim();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 48),
            Text(
              "Danke, dass du uns hilfst das Spiel noch besser zu machen!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
            SizedBox(height: 48),
            Row(
              children: [
                MySecondaryTextButton(
                  text: "Abbrechen",
                  onPressed: () => widget.onClose,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: MyPrimaryTextButton(
                    text: "Senden",
                    onPressed: () {
                      // TODO
                    },
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
