import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/widgets/common/my_icon_button.dart';

import '../../screens/game_page.dart';
import '../common/my_buttons.dart';
import '../common/util/icon_styled_text.dart';
import 'bottom_content.dart';

class CombinationArea extends StatelessWidget {

  const CombinationArea({
    super.key,
    required this.selectedModifier,
    required this.selectedHead,
    required this.onResetSelection,
    required this.maxAttempts,
    required this.attemptsLeft,
    required this.wordCompletionEventStream,
    required this.isReportVisible,
    required this.onReportPressed,
  });

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;
  final int maxAttempts;
  final int attemptsLeft;
  final Stream<String> wordCompletionEventStream;
  final bool isReportVisible;
  final Function() onReportPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CompoundMergeRow(
          selectedModifier: selectedModifier,
          selectedHead: selectedHead,
          onResetSelection: onResetSelection,
          maxAttempts: maxAttempts,
          attemptsLeft: attemptsLeft,
          isReportVisible: isReportVisible,
          onReportPressed: onReportPressed,
        ),
        AnimatedTextFadeOut(
          textStream: wordCompletionEventStream,
        ),
      ],
    );
  }
}





class AnimatedTextFadeOut extends StatefulWidget {
  const AnimatedTextFadeOut({super.key, required this.textStream});

  final Stream<String> textStream;

  @override
  AnimatedTextFadeOutState createState() => AnimatedTextFadeOutState();
}

class AnimatedTextFadeOutState extends State<AnimatedTextFadeOut>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _alignAnimation;
  late CurvedAnimation curve;
  late StreamSubscription<String> _textStreamSubscription;

  String _displayText = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      reverseDuration: const Duration(milliseconds: 1500),
    );

    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.topCenter, // Changed because the controller is reversed
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _textStreamSubscription = widget.textStream.listen((text) {
      _displayText = text;
      _controller.reverse(from: 1.0);
    });
  }

  @override
  void dispose() {
    _textStreamSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayText.isEmpty) {
      return Container();
    }
    return AlignTransition(
      alignment: _alignAnimation,
      child: FadeTransition(
        opacity: _controller,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _displayText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class CompoundMergeRow extends StatelessWidget {
  const CompoundMergeRow({
    super.key,
    required this.selectedModifier,
    required this.selectedHead,
    required this.onResetSelection,
    required this.maxAttempts,
    required this.attemptsLeft,
    required this.isReportVisible,
    required this.onReportPressed,
  });

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;
  final int maxAttempts;
  final int attemptsLeft;
  final bool isReportVisible;
  final Function() onReportPressed;

  final _placeholder = "    ";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerRight,
            child: ComponentWithHint(
              hint: selectedModifier?.hint?.type,
              size: 32.0,
              button: MyPrimaryTextButtonLarge(
                onPressed: () {
                  onResetSelection(SelectionType.modifier);
                },
                text: selectedModifier?.component.text ?? _placeholder,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            height: 140,
            child: Column(
              children: [
                Expanded(
                  child: AnimatedOpacity(
                    opacity: isReportVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Center(
                      child: MyIconButton(
                        icon: FontAwesomeIcons.flag,
                        onPressed: onReportPressed,
                      ),
                    ),
                  ),
                ),
                Expanded(child: Center(child: IconStyledText(text: "+"))),
                Expanded(
                  child: Text(
                    attemptsLeft < maxAttempts ? "$attemptsLeft/$maxAttempts" : "",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: ComponentWithHint(
              hint: selectedHead?.hint?.type,
              size: 32.0,
              button: MyPrimaryTextButtonLarge(
                onPressed: () {
                  onResetSelection(SelectionType.head);
                },
                text: selectedHead?.component.text ?? _placeholder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

