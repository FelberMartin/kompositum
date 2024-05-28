
import 'package:flutter/material.dart';

import '../game/game_event/game_event_stream.dart';
import 'audio_manager.dart';

class AppLifecycleReactor extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      AudioManager.instance.dispose();
    } else if (state == AppLifecycleState.detached) {
      GameEventStream.instance.close();
    }
  }
}