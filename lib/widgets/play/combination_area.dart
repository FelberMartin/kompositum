import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/game/game_event.dart';
import 'package:kompositum/widgets/common/my_icon_button.dart';
import 'package:kompositum/widgets/common/shake_widget.dart';

import '../../screens/game_page.dart';
import '../../util/audio_manager.dart';
import '../common/my_buttons.dart';
import '../common/util/icon_styled_text.dart';
import 'bottom_content.dart';

class CombinationArea extends StatefulWidget {

  const CombinationArea({
    super.key,
    required this.selectedModifier,
    required this.selectedHead,
    required this.onResetSelection,
    required this.maxAttempts,
    required this.attemptsLeft,
    required this.gameEventStream,
    required this.isReportVisible,
    required this.onReportPressed,
    required this.progress,
  });

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;
  final int maxAttempts;
  final int attemptsLeft;
  final Stream<GameEvent> gameEventStream;
  final bool isReportVisible;
  final Function() onReportPressed;
  final double progress;

  factory CombinationArea.loading(stream) => CombinationArea(
    selectedModifier: null,
    selectedHead: null,
    onResetSelection: (type) {},
    maxAttempts: 0,
    attemptsLeft: 0,
    gameEventStream: stream,
    isReportVisible: false,
    onReportPressed: () {},
    progress: 0.0,
  );

  @override
  State<CombinationArea> createState() => _CombinationAreaState();
}

class _CombinationAreaState extends State<CombinationArea> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Align(
        //   alignment: Alignment.topCenter,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 12.0),
        //     child: ProgressBar(progress: widget.progress),
        //   )
        // ),
        CompoundMergeRow(
          selectedModifier: widget.selectedModifier,
          selectedHead: widget.selectedHead,
          onResetSelection: widget.onResetSelection,
          maxAttempts: widget.maxAttempts,
          attemptsLeft: widget.attemptsLeft,
          isReportVisible: widget.isReportVisible,
          onReportPressed: widget.onReportPressed,
          gameEventStream: widget.gameEventStream,
        ),
        AnimatedTextFadeOut(
          gameEventStream: widget.gameEventStream,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyIconButton(
              icon: AudioManager.instance.isMuted ? MyIcons.muted : MyIcons.unmuted,
              additionalPadding: const EdgeInsets.only(right: 2.0, left: -2.0),
              onPressed: () {
                AudioManager.instance.toggleMute();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AudioManager.instance.isMuted
                        ? "Lautlos"
                        : "Ton an"),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
                setState(() {});
              },
            ),
          ),
        )
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 14,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.centerLeft,
          widthFactor: progress == 0.0 ? 0.07 : progress,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}





class AnimatedTextFadeOut extends StatefulWidget {
  const AnimatedTextFadeOut({super.key, required this.gameEventStream});

  final Stream<GameEvent> gameEventStream;

  @override
  AnimatedTextFadeOutState createState() => AnimatedTextFadeOutState();
}

class AnimatedTextFadeOutState extends State<AnimatedTextFadeOut>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<AlignmentGeometry> _alignAnimation;
  late StreamSubscription<GameEvent> _gameEventStreamSubscription;

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

    _gameEventStreamSubscription = widget.gameEventStream.listen((gameEvent) {
      if (gameEvent is CompoundFoundGameEvent) {
        _displayText = gameEvent.compound.name;
        _controller.reverse(from: 1.0);
      }
    });
  }

  @override
  void dispose() {
    _gameEventStreamSubscription.cancel();
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

class CompoundMergeRow extends StatefulWidget {
  const CompoundMergeRow({
    super.key,
    required this.selectedModifier,
    required this.selectedHead,
    required this.onResetSelection,
    required this.maxAttempts,
    required this.attemptsLeft,
    required this.isReportVisible,
    required this.onReportPressed,
    required this.gameEventStream,
  });

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;
  final int maxAttempts;
  final int attemptsLeft;
  final bool isReportVisible;
  final Function() onReportPressed;
  final Stream<GameEvent> gameEventStream;

  @override
  State<CompoundMergeRow> createState() => _CompoundMergeRowState();
}

class _CompoundMergeRowState extends State<CompoundMergeRow> with SingleTickerProviderStateMixin {
  final _placeholder = "    ";

  late StreamSubscription<GameEvent> _textStreamSubscription;

  double _scale = 1.0;
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();

    _textStreamSubscription = widget.gameEventStream.listen((gameEvent) {
      if (gameEvent is CompoundFoundGameEvent) {
        _onWordCompletion();
      } else if (gameEvent is CompoundInvalidGameEvent) {
        _shakeKey.currentState?.shake();
      }
    });
  }

  void _onWordCompletion() {
    _scale = 1.6;
    Future.delayed(Duration(milliseconds: 50), () {
      _scale = 1.0;
    });
  }

  @override
  void dispose() {
    _textStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Function(Widget) animateScale = (child) {
      return AnimatedScale(
        duration: Duration(milliseconds: 50),
        curve: Curves.easeInCubic,
        scale: _scale,
        child: child,
      );
    };

    final componentLeft = _buildComponentButton(widget.selectedModifier, SelectionType.modifier);
    final componentLeftWrapped = Expanded(
      flex: 1,
      child: Container(
          alignment: Alignment.centerRight,
          child: componentLeft,
      ),
    );

    final componentRight = _buildComponentButton(widget.selectedHead, SelectionType.head);
    final componentRightWrapped = Expanded(
      flex: 1,
      child: Container(
          alignment: Alignment.centerLeft,
          child: componentRight,
      ),
    );

    final reportButton = MyIconButton(
      icon: MyIcons.report,
      onPressed: widget.onReportPressed,
    );
    final reportButtonAnimated = AnimatedOpacity(
      opacity: widget.isReportVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: reportButton,
    );
    final plusSign = Expanded(
      child: Center(
        child: ShakeWidget(
          key: _shakeKey,
          duration: const Duration(milliseconds: 300),
          child: Center(child: animateScale(IconStyledText(
          text: "+",
        ),
      ),),)
      ),
    );
    final attemptsCounter = Expanded(
      child: Text(
        widget.attemptsLeft < widget.maxAttempts ? "${widget.attemptsLeft}/${widget.maxAttempts}" : "",
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    final middleColumn = Column(
      children: [
        reportButtonAnimated,
        plusSign,
        attemptsCounter,
      ],
    );
    final middleColumnWrapped = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 156,
          child: middleColumn,
        ),
    );

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        componentLeftWrapped,
        middleColumnWrapped,
        componentRightWrapped,
      ],
    );

    return row;
  }

  Widget _buildComponentButton(ComponentInfo? componentInfo, SelectionType type) {
    final button = MyPrimaryTextButtonLarge(
      onPressed: () {
        widget.onResetSelection(type);
      },
      text: componentInfo?.component.text ?? _placeholder,
    );
    return ComponentWithHint(
      hint: widget.selectedModifier?.hint?.type,
      size: 32.0,
      button: button,
    );
  }
}

