import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/util/extensions/color_util.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';

import '../../../config/my_theme.dart';
import '../../../data/remote/firestore.dart';
import '../../../firebase_options.dart';
import '../../common/my_3d_container.dart';
import '../../common/util/icon_styled_text.dart';

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
        levelIdentifier: 1,
        onClose: () {},
      )));
}

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.modifier,
    required this.head,
    required this.levelIdentifier,
    required this.onClose,
  });

  final String modifier;
  final String head;
  final Object levelIdentifier;
  final Function onClose;

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {

  String compoundText = "";
  Future<void>? sendFuture;

  void onSendPressed() async {
    setState(() {
      sendFuture = sendDataToFirestore(compoundText, widget.modifier, widget.head, widget.levelIdentifier.toString());
    });
    await sendFuture;
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return MyDialog(
        title: "Du hast ein fehlendes Wort gefunden?",
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: ComponentWrapper(widget.modifier)),
                SizedBox(width: 8),
                IconStyledText(text: "+", strokeWidth: 2),
                SizedBox(width: 8),
                Flexible(child: ComponentWrapper(widget.head)),
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
    return Row(
      children: [
        MySecondaryTextButton(
          text: "Abbrechen",
          onPressed: onCancelPressed,
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
                        : MyColorPalette.of(context).textSecondary,
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
    return My3dContainer(
      topColor: MyColorPalette.of(context).textSecondary,
      sideColor: MyColorPalette.of(context).textSecondary.darken(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0) + const EdgeInsets.all(12.0),
        child: FittedBox(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
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
    return Row(
      children: [
        IconStyledText(text: "="),
        SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Wort eingeben",
              hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: MyColorPalette.of(context).primary,
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: MyColorPalette.of(context).textSecondary,
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
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }
}
