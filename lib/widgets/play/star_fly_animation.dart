

import 'dart:io';

import 'package:flutter/material.dart';

import '../../config/theme.dart';


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

  @override
  void initState() {
    super.initState();
    widget.starIncreaseRequestStream.listen((request) {
      const delay = 100;
      for (var i = 0; i < request.amount; i++) {
        Future.delayed(Duration(milliseconds: i * delay), () {
          var key = UniqueKey();
          keys[key] = request.origin;
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (keys.isEmpty) return Container();
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        for (var entries in keys.entries)
          StarFlyAnimation(
            key: entries.key,
            begin: entries.value == Origin.compoundCompletion
                ? Offset(size.width / 2, size.height / 3.5)
                : Offset(size.width / 2, size.height / 2),
            onAnimationEnd: () {
              widget.onIncreaseStarCount.call(1);
              keys.remove(entries.key);
            },
          ),
      ],
    );
  }

}



class StarFlyAnimation extends StatefulWidget {
  static const duration = Duration(milliseconds: 1000);

  const StarFlyAnimation({
    required this.begin,
    this.onAnimationEnd,
    super.key,
  });

  final Offset begin;
  final Function? onAnimationEnd;

  @override
  State<StarFlyAnimation> createState() => _StarFlyAnimationState();
}

class _StarFlyAnimationState extends State<StarFlyAnimation> with SingleTickerProviderStateMixin {

  late Offset _end;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _end = Offset(size.width / 1.1, 40);

    final customColors = Theme.of(context).extension<CustomColors>()!;
    return TweenAnimationBuilder(
      tween: BezierTween(
        begin: widget.begin,
        control: Offset(size.width / 1.2, size.height / 4),
        end: _end,
      ),
      duration: StarFlyAnimation.duration,
      curve: Curves.easeInBack,
      onEnd: () {
        widget.onAnimationEnd?.call();
      },
      builder: (BuildContext context, Offset value, Widget? child) {
        return Positioned(
          left: value.dx,
          top: value.dy,
          child: AnimatedOpacity(
            opacity: value.dx < size.width / 1.45 ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            child: Icon(
              Icons.star_rounded,
              color: customColors.star,
              size: 32,
            ),
          )
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
