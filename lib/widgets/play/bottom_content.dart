import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/theme.dart';
import '../../game/hints/hint.dart';
import '../../screens/game_page.dart';
import '../common/util/rounded_edge_clipper.dart';
import '../common/my_buttons.dart';
import '../common/my_icon_button.dart';

class BottomContent extends StatelessWidget {
  const BottomContent({
    super.key,
    required this.onToggleSelection,
    required this.componentInfos,
    required this.hiddenComponentsCount,
    required this.hintButtonInfo,
  });

  final Function(int) onToggleSelection;
  final List<ComponentInfo> componentInfos;
  final int hiddenComponentsCount;
  final MyIconButtonInfo hintButtonInfo;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return ClipPath(
      clipper: RoundedEdgeClipper(onBottom: false),
      child: Container(
        height: 400,
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  for (final componentInfo in componentInfos)
                    WordWrapper(
                      text: componentInfo.component.text,
                      selectionType: componentInfo.selectionType,
                      onSelectionChanged: (selected) {
                        onToggleSelection(componentInfo.component.id);
                      },
                      hint: componentInfo.hint?.type,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HiddenComponentsIndicator(
                    hiddenComponentsCount: hiddenComponentsCount,
                  ),
                  Column(
                    children: [
                      MyIconButton.fromInfo(
                        info: hintButtonInfo,
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Text(
                            "100",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                              color: customColors.textSecondary,
                            ),
                          ),
                          Icon(
                            Icons.star_rounded,
                            color: customColors.star,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    if (hiddenComponentsCount == 0) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$hiddenComponentsCount",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text("verdeckte Wörter",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: customColors.textSecondary,
            ))
      ],
    );
  }
}

class WordWrapper extends StatelessWidget {
  const WordWrapper({
    super.key,
    required this.text,
    required this.selectionType,
    required this.onSelectionChanged,
    this.hint,
  });

  final String text;
  final SelectionType? selectionType;
  final ValueChanged<bool> onSelectionChanged;
  final HintComponentType? hint;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionType != null;
    final button = isSelected ?
    MyPrimaryTextButton(
      onPressed: () {
        onSelectionChanged(false);
      },
      text: text,
    )
        : MySecondaryTextButton(
      onPressed: () {
        onSelectionChanged(true);
      },
      text: text,
    );

    return ComponentWithHint(button: button, hint: hint);
  }
}

class ComponentWithHint extends StatelessWidget {
  const ComponentWithHint({
    super.key,
    required this.button,
    required this.hint,
    this.size = 24.0,
  });

  final StatelessWidget button;
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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        FontAwesomeIcons.lightbulb,
        color: customColors.star,
        size: size * 0.6,
      ),
    );
  }
}