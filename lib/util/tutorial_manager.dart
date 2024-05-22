import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kompositum/game/game_event/game_event.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/widgets/play/dialogs/tutorials/hidden_components_tutorial_dialog.dart';
import 'package:kompositum/widgets/play/dialogs/tutorials/hints_tutorial_dialog.dart';

import '../config/star_costs_rewards.dart';
import '../data/key_value_store.dart';
import '../data/models/unique_component.dart';
import '../game/level_setup_provider.dart';
import '../widgets/play/dialogs/tutorials/missing_compound_tutorial_dialog.dart';

enum TutorialPart {
  CLICK_INDICATOR,    // Note: This is currently not used.
  MISSING_COMPOUND,
  HINTS,
  HIDDEN_COMPONENTS,
}


class TutorialManager {

  final KeyValueStore _keyValueStore;
  Function(Widget)? animateDialog;
  StreamSubscription<GameEvent>? _gameEventStreamSubscription;

  /** At which index the click indicator should be shown. -1 means no indicator. */
  int showClickIndicatorIndex = -1;

  TutorialManager(this._keyValueStore);

  void registerGameEventStream(Stream<GameEvent> gameEventStream) {
    _gameEventStreamSubscription = gameEventStream.listen((event) {
      if (event is NewLevelStartGameEvent) {
        _onNewLevelStart(event.levelSetup, event.gameLevel);
      } else if (event is ComponentClickedGameEvent) {
        _onComponentClicked();
      } else if (event is CompoundInvalidGameEvent) {
        _onCombinedInvalidCompound(event.gameLevel);
      }
    });
  }

  void deregisterGameEventStream() {
    _gameEventStreamSubscription?.cancel();
    animateDialog = null;
  }

  void _onNewLevelStart(LevelSetup levelSetup, GameLevel gameLevel) {
    _checkClickIndicator(levelSetup.levelIdentifier, gameLevel.shownComponents);
    _checkHiddenComponents(gameLevel.hiddenComponents.length);
  }

  void _checkClickIndicator(Object levelIdentifier, List<UniqueComponent> shownComponents) async {
    // Always show the click indicator for the first level. Regardless of whether it was already shown.
    if (levelIdentifier == 1) {
      // The first level is always "Wort" + "Schatz".
      showClickIndicatorIndex = shownComponents.indexWhere((component) => component.text == "Wort");
    }
  }

  void _checkHiddenComponents(int hiddenComponentsCount) async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.HIDDEN_COMPONENTS);
    if (!shown && hiddenComponentsCount > 0) {
      animateDialog?.call(HiddenComponentsTutorialDialog());
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.HIDDEN_COMPONENTS);
    }
  }

  void _onComponentClicked() {
    showClickIndicatorIndex = -1;
  }

  void _onCombinedInvalidCompound(GameLevel gameLevel) {
    _checkMissingCompound();
    _checkHints(gameLevel.attemptsWatcher.overAllAttemptsFailed);
  }

  void _checkMissingCompound() async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.MISSING_COMPOUND);
    if (!shown) {
      animateDialog?.call(MissingCompoundTutorialDialog());
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.MISSING_COMPOUND);
    }
  }

  void _checkHints(int overAllAttemptsFailed) async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.HINTS);
    if (!shown && overAllAttemptsFailed >= 2) {
      animateDialog?.call(HintsTutorialDialog());
      Costs.freeHintAvailable = true;
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.HINTS);
    }
  }
}