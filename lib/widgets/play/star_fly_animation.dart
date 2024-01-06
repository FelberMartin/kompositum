import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/my_theme.dart';

class StarIncreaseRequest {
  final int amount;
  final Origin origin;

  StarIncreaseRequest(this.amount, this.origin);
}

enum Origin {
  compoundCompletion,
  levelCompletion,
}

class StarFlyAnimations extends StatefulWidget {
  const StarFlyAnimations({
    required this.starIncreaseRequestStream,
    required this.onIncreaseStarCount,
    super.key,
  });

  final Stream<StarIncreaseRequest> starIncreaseRequestStream;
  final Function(int) onIncreaseStarCount;

  @override
  State<StarFlyAnimations> createState() => _StarFlyAnimationsState();
}

class _StarFlyAnimationsState extends State<StarFlyAnimations> {

  Map<Key, Origin> keys = {};
  late StreamSubscription<StarIncreaseRequest> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.starIncreaseRequestStream.listen((request) {
      const delay = 100;
      for (var i = 0; i < request.amount; i++) {
        Future.delayed(Duration(milliseconds: i * delay), () {
          if (!mounted) return;
          var key = UniqueKey();
          keys[key] = request.origin;
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (keys.isEmpty) return Container();
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        for (var entries in keys.entries)
          _StarFlyAnimationWrapper(
            key: entries.key,
            begin: entries.value == Origin.compoundCompletion
                ? Offset(size.width / 2, size.height / 3.5)
                : Offset(size.width / 2, size.height / 2),
            onAnimationEnd: () {
              if (!mounted) return;
              widget.onIncreaseStarCount.call(1);
              keys.remove(entries.key);
            },
          ),
      ],
    );
  }
}

class _StarFlyAnimationWrapper extends StatefulWidget {
  const _StarFlyAnimationWrapper({
    required this.begin,
    required this.onAnimationEnd,
    super.key,
  });

  final Offset begin;
  final Function() onAnimationEnd;

  @override
  State<_StarFlyAnimationWrapper> createState() => _StarFlyAnimationWrapperState();
}

class _StarFlyAnimationWrapperState extends State<_StarFlyAnimationWrapper> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward().whenCompleteOrCancel(widget.onAnimationEnd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StarFlyAnimation(
      begin: widget.begin,
      controller: _controller,
    );
  }
}

class _StarFlyAnimation extends StatelessWidget {
  _StarFlyAnimation({
    required this.begin,
    required this.controller,
    super.key,
  });

  final Offset begin;
  final Animation<double> controller;

  late final Animation<double> _opacity = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: const Interval(0.8, 1.0),
  ));
  late final Animation<double> _sizeGrow = Tween<double>(
    begin: 0,
    end: 48,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: const Interval(0.0, 0.04, curve: Curves.easeOut),
  ));
  late final Animation<double> _sizeShrink = Tween<double>(
    begin: 48,
    end: 24,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
  ));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final position = BezierTween(
      begin: begin,
      control: Offset(size.width / 1.2, size.height / 4),
      end: Offset(size.width / 1.1, 40),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInBack,
    ));

    final customColors = Theme.of(context).extension<CustomColors>()!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: position.value.dx,
          top: position.value.dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Icon(
              Icons.star_rounded,
              color: customColors.star,
              size: min(_sizeGrow.value, _sizeShrink.value),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BezierTween extends Tween<Offset> {
  final Offset begin;
  final Offset end;
  final Offset control;

  BezierTween({required this.begin, required this.end, required this.control})
      : super(begin: begin, end: end);

  @override
  Offset lerp(double t) {
    final t1 = 1 - t;
    return begin * t1 * t1 + control * 2 * t1 * t + end * t * t;
  }
}
