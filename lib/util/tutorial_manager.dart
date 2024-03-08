import '../config/star_costs_rewards.dart';
import '../data/key_value_store.dart';
import '../data/models/unique_component.dart';
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';

enum TutorialPart {
  CLICK_INDICATOR,
  MISSING_COMPOUND,
  HINTS,
  HIDDEN_COMPONENTS,
}


class TutorialManager {

  final KeyValueStore _keyValueStore;

  /** At which index the click indicator should be shown. -1 means no indicator. */
  int showClickIndicatorIndex = -1;

  TutorialManager(this._keyValueStore);

  void onNewLevelStart(LevelSetup levelSetup, PoolGameLevel poolGameLevel) {
    _checkClickIndicator(levelSetup.levelIdentifier, poolGameLevel.shownComponents);
    _checkHiddenComponents(poolGameLevel.hiddenComponents.length);
  }

  void _checkClickIndicator(Object levelIdentifier, List<UniqueComponent> shownComponents) async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.CLICK_INDICATOR);
    if (!shown && levelIdentifier == 1) {
      // The first level is always "Wort" + "Schatz".
      showClickIndicatorIndex = shownComponents.indexWhere((component) => component.text == "Wort");
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.CLICK_INDICATOR);
    }
  }

  void _checkHiddenComponents(int hiddenComponentsCount) async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.HIDDEN_COMPONENTS);
    if (!shown && hiddenComponentsCount > 0) {
      // TODO: show dialog
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.HIDDEN_COMPONENTS);
    }
  }

  void onComponentClicked() {
    showClickIndicatorIndex = -1;
  }

  void onCombinedInvalidCompound(PoolGameLevel poolGameLevel) {
    _checkMissingCompound();
    _checkHints(poolGameLevel.attemptsWatcher.overAllAttemptsFailed);
  }

  void _checkMissingCompound() async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.MISSING_COMPOUND);
    if (!shown) {
      // TODO: show dialog
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.MISSING_COMPOUND);
    }
  }

  void _checkHints(int overAllAttemptsFailed) async {
    final shown = await _keyValueStore.wasTutorialPartShown(TutorialPart.HINTS);
    if (!shown && overAllAttemptsFailed >= 2) {
      // TODO: show dialog
      Costs.freeHintAvailable = true;
      await _keyValueStore.storeTutorialPartAsShown(TutorialPart.HINTS);
    }
  }


}