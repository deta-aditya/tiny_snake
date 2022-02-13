import 'dart:collection';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_snake/model/direction.dart';
import 'package:tiny_snake/model/food.dart';
import 'package:tiny_snake/model/game/game.dart';

import 'package:tiny_snake/model/game/i_game.dart';
import 'package:tiny_snake/model/game_loop.dart';
import 'package:tiny_snake/model/position.dart';
import 'package:tiny_snake/model/snake.dart';

void main() {
  group('GameLoop', () {
    test('when game is started then start the timer', () {
      final game = FakeGame(FakeGameAction.startOnNextLoop);
      final loop = GameLoop(game);

      game.next(Start(100.0, 100.0));

      expect(loop.timer, isNotNull);
      expect(loop.timer?.isActive, true);

      loop.stop();
    });

    test('when game is paused then stop the timer', () {
      final game = FakeGame(FakeGameAction.pauseOnNextLoop);
      final loop = GameLoop(game);

      game.next(Pause());

      expect(loop.timer, isNull);
    });

    test('when game is lost then stop the timer', () async {
      final game = FakeGame(FakeGameAction.overOnNextLoop);
      final loop = GameLoop(game);

      await Future.delayed(Duration(milliseconds: 100));

      expect(loop.timer, isNull);
      loop.stop();
    });

    test('when period of game changed then refresh the timer', () async {
      final game = FakeGame(FakeGameAction.eatOnNextLoop);
      final loop = GameLoop(game);

      game.next(Loop());

      final previousTimer = loop.timer;
      await Future.delayed(Duration(milliseconds: 200));

      expect(loop.timer, allOf(isNotNull, isNot(previousTimer)));
      loop.stop();
    });
  });
}

class FakeGame implements IGame {
  final FakeGameAction action;
  late int period;
  late IGameState state;

  VoidCallback? _listener;

  FakeGame(this.action) {
    period = 100;
    state = NotStarted();
  }

  @override
  Food generateFood(int xBoundary, int yBoundary) {
    throw UnimplementedError();
  }

  @override
  Snake generateSnake(int xBoundary, int yBoundary, int length) {
    throw UnimplementedError();
  }

  @override
  void listen(VoidCallback listener) {
    _listener = listener;
  }

  @override
  void next(IGameAction _) {
    final dummyPosition = Position(left: 1, top: 1);
    final dummySnake = Snake.create(initialPosition: dummyPosition, length: 4);
    final dummyFood = Food(position: dummyPosition, weight: 1);
    final dummyPlayingState = Playing(
      xBoundary: 100,
      yBoundary: 100,
      snake: dummySnake,
      currentDirection: Direction.up,
      food: dummyFood,
      score: 0,
      directionBuffer: ListQueue.of([]),
    );

    switch (action) {
      case FakeGameAction.startOnNextLoop:
        state = dummyPlayingState;
        break;
      case FakeGameAction.pauseOnNextLoop:
        state = Pausing(dummyPlayingState);
        break;
      case FakeGameAction.overOnNextLoop:
        state = GameOver(
          xBoundary: 100,
          yBoundary: 100,
          snake: dummySnake,
          food: dummyFood,
          score: 0,
          reason: GameOverReason.outOfBound,
        );
        break;
      case FakeGameAction.eatOnNextLoop:
        state = dummyPlayingState;
        period += 1;
        break;
    }
    _listener!();
  }
}

enum FakeGameAction {
  startOnNextLoop,
  pauseOnNextLoop,
  overOnNextLoop,
  eatOnNextLoop,
}
