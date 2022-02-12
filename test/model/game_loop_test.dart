import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:tiny_snake/model/game/i_game.dart';
import 'package:tiny_snake/model/game_loop.dart';

import 'game_loop_test.mocks.dart';

@GenerateMocks([IGame])
void main() {
  group('GameLoop', () {
    test('when instantiated then add listener to game', () {
      final game = MockIGame();
      GameLoop(game);

      verify(game.addListener(any)).called(1);
    });

    test('when game is started becomes true then start the timer', () {
      final game = FakeGame(isStarted: true);
      final loop = GameLoop(game);

      game.notifyListeners();

      expect(loop.timer, isNotNull);
      expect(loop.timer?.isActive, true);

      loop.stop();
    });

    test('when game is paused becomes true then stop the timer', () {
      final game = FakeGame(isPaused: true);
      final loop = GameLoop(game);

      game.notifyListeners();

      expect(loop.timer, isNull);
    });

    test('when game is lost becomes true then stop the timer', () {
      final game = FakeGame(isGameLost: true);
      final loop = GameLoop(game);

      game.notifyListeners();

      expect(loop.timer, isNull);
    });
  });
}

class FakeGame extends IGame {
  late bool _isGameLost;
  late bool _isStarted;
  late bool _isPaused;

  FakeGame({
    bool? isGameLost,
    bool? isStarted,
    bool? isPaused,
  })  : _isGameLost = isGameLost ?? false,
        _isStarted = isStarted ?? false,
        _isPaused = isPaused ?? false;

  @override
  bool get isGameLost => _isGameLost;

  @override
  bool get isPaused => _isPaused;

  @override
  bool get isStarted => _isStarted;

  @override
  int get period => 250;

  @override
  LoopResult loop() {
    notifyListeners();
    return LoopResult.ok;
  }
}
