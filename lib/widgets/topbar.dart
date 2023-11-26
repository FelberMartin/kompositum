import 'package:flutter/material.dart';
import 'package:kompositum/util/clip_shadow_path.dart';

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const height = 20;
    Path path = Path();
    path.lineTo(0, size.height - height);
    path.addArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - height),
        height: height * 2,
        width: size.width,
      ),
      3.14,
      -3.14,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    required this.leftContent,
    required this.middleContent,
    required this.rightContent,
    super.key,
  });

  final Widget leftContent;
  final Widget middleContent;
  final Widget rightContent;

  @override
  Size get preferredSize => Size.fromHeight(80.0); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return ClipShadowPath(
      clipper: MyClipper(),
      shadow: Shadow(
        color: Theme.of(context).colorScheme.shadow,
        blurRadius: 2,
      ),
      child: Container(
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          clipBehavior: Clip.none,
          leading: leftContent,
          title: middleContent,
          centerTitle: true,
          actions: [rightContent],
        ),
      ),
    );
  }
}

class ContainerTopBar extends StatelessWidget {
  const ContainerTopBar({
    required this.leftContent,
    required this.middleContent,
    required this.rightContent,
    super.key,
  });

  final Widget leftContent;
  final Widget middleContent;
  final Widget rightContent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipShadowPath(
        clipper: MyClipper(),
        shadow: Shadow(
          color: Theme.of(context).colorScheme.shadow,
          blurRadius: 2,
        ),
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: leftContent),
              Expanded(child: middleContent),
              Expanded(child: rightContent),
            ],
          ),
        ),
      ),
    );
  }
}
