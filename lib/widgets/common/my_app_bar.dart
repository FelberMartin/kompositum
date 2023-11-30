import 'package:flutter/material.dart';
import 'package:kompositum/util/clip_shadow_path.dart';
import 'package:kompositum/util/rounded_edge_clipper.dart';



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
      clipper: RoundedEdgeClipper(onTop: false),
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
