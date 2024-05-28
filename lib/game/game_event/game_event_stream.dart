import 'dart:async';

import 'game_event.dart';

class GameEventStream {
  static final GameEventStream instance = GameEventStream._();

  GameEventStream._();

  final StreamController<GameEvent> _controller = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get stream => _controller.stream;

  void addEvent(GameEvent event) {
    _controller.add(event);
  }

  void close() {
    _controller.close();
  }

  bool get isClosed => _controller.isClosed;
}