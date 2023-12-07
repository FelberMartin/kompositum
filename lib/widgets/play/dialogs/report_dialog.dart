import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';
import 'package:kompositum/widgets/play/combination_area.dart';

import '../../../config/theme.dart';
import '../../../data/remote/firestore.dart';
import '../../../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
      theme: myTheme,
      home: ReportDialog(
        modifier: "Baum",
        head: "Schuh",
        onClose: () {},
      )));
}

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
  Future<void>? sendFuture;

  void onSendPressed() async {
    setState(() {
      sendFuture = sendDataToFirestore(compoundText, widget.modifier, widget.head);
    });
    await sendFuture;
    widget.onClose();
  }

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
                ComponentWrapper(widget.modifier),
                SizedBox(width: 8),
                IconStyledText(text: "+", strokeWidth: 2),
                SizedBox(width: 8),
                ComponentWrapper(widget.head),
              ],
            ),
            SizedBox(height: 24),
            InputRow(
              onChanged: (text) {
                setState(() {
                  compoundText = text.trim();
                });
              },
            ),
            SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Danke, dass du uns hilfst das Spiel noch besser zu machen!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
              ),
            ),
            SizedBox(height: 48),
            ActionButtonRow(
              isSendEnabled: compoundText.isNotEmpty && sendFuture == null,
              sendFuture: sendFuture,
              onCancelPressed: () {
                widget.onClose();
              },
              onSendPressed: onSendPressed,
            ),
          ],
        ));
  }
}

class ActionButtonRow extends StatelessWidget {
  const ActionButtonRow({
    super.key,
    required this.isSendEnabled,
    required this.onCancelPressed,
    required this.onSendPressed,
    this.sendFuture,
  });

  final bool isSendEnabled;
  final Function onCancelPressed;
  final Function onSendPressed;
  final Future<void>? sendFuture;


  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      children: [
        MySecondaryTextButton(
          text: "Abbrechen",
          onPressed: () => onCancelPressed,
        ),
        SizedBox(width: 8),
        FutureBuilder<void>(
            future: sendFuture,
            builder: (context, snapshot) {
              var content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                content = Icon(
                  FontAwesomeIcons.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                );
              } else if (snapshot.hasError) {
                content = Icon(
                  FontAwesomeIcons.times,
                  color: Theme.of(context).colorScheme.error,
                );
              } else {
                content = Text(
                  "Senden",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: isSendEnabled
                        ? Theme.of(context).colorScheme.onPrimary
                        : customColors.textSecondary,
                  ),
                );
              }

              return Expanded(
                child: MyPrimaryButton(
                  enabled: isSendEnabled,
                  onPressed: onSendPressed,
                  child: Center(child: content),
                ),
              );
          }
        ),
      ],
    );
  }
}

class ComponentWrapper extends StatelessWidget {
  const ComponentWrapper(
      this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return My3dContainer(
      topColor: customColors.textSecondary,
      sideColor: customColors.background4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}

class InputRow extends StatelessWidget {
  const InputRow({
    super.key,
    required this.onChanged,
  });

  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
