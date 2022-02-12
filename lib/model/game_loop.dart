import 'dart:async';

import 'game/i_game.dart';


class GameLoop {
  Timer? _timer;
  IGame _game;

  Timer? get timer => _timer;

  GameLoop(IGame game) : _game = game {
    _game.addListener(_handleGameChange);
  }

  void start() {
    _timer = _generateTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _handleGameChange() {
    if (_game.isPaused || _game.isGameLost) {
      return stop();
    }

    if (_game.isStarted && _timer == null) {
      return start();
    }
  }

  Timer _generateTimer() {
    return Timer.periodic(
      Duration(milliseconds: _game.period), (timer) {
        final result = _game.loop();
        
        switch (result) {
          case LoopResult.needStop:
            timer.cancel();
            break;
          case LoopResult.needRefresh:
            timer.cancel();
            _timer = _generateTimer();
            break;
          default:
        }
      },
    );
  }
}
