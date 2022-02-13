import 'dart:async';

import 'package:tiny_snake/model/game/game.dart';

import 'game/i_game.dart';


class GameLoop {
  Timer? _timer;
  IGame _game;

  Timer? get timer => _timer;

  GameLoop(IGame game) : _game = game {
    _game.listen(_handleGameChange);
  }

  void start() {
    _timer = _generateTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _handleGameChange() {
    final state = _game.state;

    if (state is Pausing || state is GameOver) {
      return stop();
    }

    if (state is Playing && _timer == null) {
      return start();
    }
  }

  Timer _generateTimer() {
    final currentPeriod = _game.period;

    return Timer.periodic(
      Duration(milliseconds: currentPeriod), (timer) {
        _game.next(Loop());

        if (currentPeriod != _game.period) {
          timer.cancel();
          _timer = _generateTimer();
        }
      },
    );
  }
}
