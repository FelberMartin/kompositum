import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/game/game_event/game_event.dart';
import 'package:kompositum/widgets/common/my_icon_button.dart';
import 'package:kompositum/widgets/common/shake_widget.dart';

import '../../config/my_theme.dart';
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
  late Animation<double> _opacityAnimation;
  late StreamSubscription<GameEvent> _gameEventStreamSubscription;

  String _displayText = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.topCenter * 0.4,
      end: Alignment.topCenter,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInExpo,
    ));

    _gameEventStreamSubscription = widget.gameEventStream.listen((gameEvent) {
      if (gameEvent is CompoundFoundGameEvent) {
        _displayText = gameEvent.compound.name;
        _controller.forward(from: 0.0);
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
        opacity: _opacityAnimation,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _displayText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: MyColorPalette.of(context).primaryShade,
            ),
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
  final _placeholder = "     ";

  late StreamSubscription<GameEvent> _textStreamSubscription;

  double _scale = 1.0;
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  static const _scaleDuration = Duration(milliseconds: 200);


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

  void _onWordCompletion() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _scale = 1.05;
    });
    await Future.delayed(_scaleDuration);
    _scale = 1.0;
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
        duration: _scaleDuration,
        curve: Curves.easeInOut,
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
          child: Center(child: IconStyledText(
          text: "+",
        ),
      ),),
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

    return animateScale(row);
  }

  Widget _buildComponentButton(ComponentInfo? componentInfo, SelectionType type) {
    final button = MyPrimaryTextButtonLarge(
      onPressed: () {
        widget.onResetSelection(type);
      },
      text: componentInfo?.component.text ?? _placeholder,
    );
    final withHint = ComponentWithHint(
      hint: componentInfo?.hint?.type,
      size: 32.0,
      button: button,
    );

    return ComponentWithLockIndicator(
      button: withHint,
      isLocked: componentInfo?.isLocked ?? false,
    );
  }
}

class ComponentWithLockIndicator extends StatelessWidget {

  const ComponentWithLockIndicator({
    super.key,
    required this.button,
    required this.isLocked,
  });

  final Widget button;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        button,
        if (isLocked)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: MyColorPalette.of(context).primaryShade,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MyIcons.lock,
                  color: MyColorPalette.of(context).onPrimary,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

