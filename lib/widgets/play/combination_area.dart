import 'dart:async';

import 'package:flutter/material.dart';

import '../../screens/game_page.dart';
import '../common/my_buttons.dart';
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
  });

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;
  final int maxAttempts;
  final int attemptsLeft;
  final Stream<String> wordCompletionEventStream;

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
  });

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;
  final int maxAttempts;
  final int attemptsLeft;

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconStyledText(text: "+"),
              Positioned(
                top: 48,
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

class IconStyledText extends StatelessWidget {
  const IconStyledText({
    super.key,
    required this.text,
    this.strokeWidth = 3.0,
    this.style = const TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.normal,
    )
  });

  final String text;
  final double strokeWidth;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round
          ..color = Theme.of(context).colorScheme.primary,
      ),
    );
  }
}