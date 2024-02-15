import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/widgets/common/my_3d_container.dart';

import '../../config/my_icons.dart';
import '../../config/my_theme.dart';
import '../../game/hints/hint.dart';
import '../../screens/game_page.dart';
import '../../util/color_util.dart';
import '../common/my_icon_button.dart';
import '../common/util/rounded_edge_clipper.dart';


const wordWrapperAnimationDuration = Duration(milliseconds: 200);

class BottomContent extends StatefulWidget {
  const BottomContent({
    super.key,
    required this.onToggleSelection,
    required this.componentInfos,
    required this.hiddenComponentsCount,
    required this.hintButtonInfo,
    this.isLoading = false,
    required this.hintCost,
  });

  final Function(int) onToggleSelection;
  final List<ComponentInfo> componentInfos;
  final int hiddenComponentsCount;
  final MyIconButtonInfo hintButtonInfo;
  final bool isLoading;
  final int hintCost;

  factory BottomContent.loading() => BottomContent(
        onToggleSelection: (id) {},
        componentInfos: [],
        hiddenComponentsCount: 0,
        hintButtonInfo: MyIconButtonInfo(
          icon: MyIcons.hint,
          onPressed: () {},
          enabled: false,
        ),
        isLoading: true,
        hintCost: Costs.hintCostBase,
      );

  @override
  State<BottomContent> createState() => _BottomContentState();
}

class _BottomContentState extends State<BottomContent> {

  List<ComponentInfo> previousComponents = [];

  @override
  Widget build(BuildContext context) {
    // Logic to animate the removal and addition of components.
    final currentComponents = widget.componentInfos;
    final removedComponents = previousComponents.where((c) => !currentComponents.contains(c)).toList();
    final addedComponents = currentComponents.where((c) => !previousComponents.contains(c)).toList();

    final allComponentsToShow = previousComponents.map((prev) {
      if (removedComponents.contains(prev)) {
        return prev;
      }
      return currentComponents.firstWhere((c) => c == prev);
    }).toList() + addedComponents;

    previousComponents = currentComponents;

    if (removedComponents.isNotEmpty || addedComponents.isNotEmpty) {
      // Delay the setState to allow the removal animation to finish.
      // The setState will trigger the animation for the added components.
      Future.delayed(wordWrapperAnimationDuration).then((value) => setState(() {}));
    }

    // ------ Widget building starts here ------
    final wrap = Wrap(
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: [
        for (final componentInfo in allComponentsToShow)
          WordWrapper(
            key: ValueKey(componentInfo.component.id),
            text: componentInfo.component.text,
            selectionType: componentInfo.selectionType,
            onSelectionChanged: (selected) {
              widget.onToggleSelection(componentInfo.component.id);
            },
            hint: componentInfo.hint?.type,
            isVisible: !removedComponents.contains(componentInfo) && !addedComponents.contains(componentInfo),
          ),
      ],
    );

    final mainContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0) + const EdgeInsets.only(top: 16.0),
        child: widget.isLoading
            ? Center(
            child: CircularProgressIndicator(
                color: MyColorPalette.of(context).textSecondary))
            : wrap
    );

    final bottomContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        HiddenComponentsIndicator(
          hiddenComponentsCount: widget.hiddenComponentsCount,
        ),
        Column(
          children: [
            MyIconButton.fromInfo(
              info: widget.hintButtonInfo,
            )
            ,
            Row(
              children: [
                Text(
                  "${widget.hintCost}",
                  style: Theme
                      .of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(
                    color: MyColorPalette.of(context).textSecondary,
                  ),
                ),
                SizedBox(width: 2.0),
                Icon(
                  MyIcons.star,
                  color: MyColorPalette.of(context).star,
                  size: 12.0,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return ClipPath(
      clipper: RoundedEdgeClipper(onBottom: false),
      child: Container(
        height: 400,
        width: double.infinity,
        color: Theme.of(context).colorScheme.secondary,
        child: Stack(
          alignment: Alignment(0.0, -0.2),  // Slightly to the top
          children: [
            SingleChildScrollView(child: mainContent),
            Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: bottomContent,
            ),
          ],
        ),
      ),
    );
  }
}

class HiddenComponentsIndicator extends StatelessWidget {
  const HiddenComponentsIndicator({
    super.key,
    required this.hiddenComponentsCount,
  });

  final int hiddenComponentsCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: hiddenComponentsCount == 0 ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFlipCounter(
              duration: const Duration(milliseconds: 300),
              value: hiddenComponentsCount,
              textStyle: Theme.of(context).textTheme.titleSmall,
              padding: const EdgeInsets.only(top: 0.0),
            ),
            Text("verdeckte Wörter",
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: MyColorPalette.of(context).textSecondary,
                    ))
          ],
        ));
  }
}

class WordWrapper extends StatelessWidget {
  const WordWrapper({
    super.key,
    required this.text,
    required this.selectionType,
    required this.onSelectionChanged,
    this.hint,
    this.isVisible = true,
  });

  final String text;
  final SelectionType? selectionType;
  final ValueChanged<bool> onSelectionChanged;
  final HintComponentType? hint;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionType != null;
    final button = My3dContainer(
      topColor: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      sideColor: isSelected
          ? MyColorPalette.of(context).primaryShade
          : MyColorPalette.of(context).secondaryShade,
      clickable: true,
      onPressed: () {
        onSelectionChanged(!isSelected);
      },
      animationDuration: wordWrapperAnimationDuration,
      child: !isVisible ? const SizedBox(width: 0, height: 40) : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
              )
        ),
      ),
    );

    return AnimatedPadding(
      duration: wordWrapperAnimationDuration,
      padding: EdgeInsets.symmetric(horizontal: !isVisible ? 0.0 : 4.0),
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: wordWrapperAnimationDuration * 1.0,
        child: ComponentWithHint(button: button, hint: hint),
      ),
    );
  }
}

class ComponentWithHint extends StatelessWidget {
  const ComponentWithHint({
    super.key,
    required this.button,
    required this.hint,
    this.size = 24.0,
  });

  final Widget button;
  final HintComponentType? hint;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (hint == null) {
      return button;
    }
    return Stack(
      alignment: const Alignment(1.1, -1.2),
      children: [
        button,
        HintIndicator(
          hintType: hint!,
          size: size,
        ),
      ],
    );
  }
}

class HintIndicator extends StatelessWidget {
  const HintIndicator({
    super.key,
    required this.hintType,
    required this.size,
  });

  final HintComponentType hintType;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        FontAwesomeIcons.lightbulb,
        color: MyColorPalette.of(context).star,
        size: size * 0.6,
      ),
    );
  }
}
