import 'package:test/test.dart';
import 'package:tiny_snake/model/direction.dart';
import 'package:tiny_snake/model/game/i_game.dart';
import 'package:tiny_snake/model/position.dart';
import 'package:tiny_snake/state/game_state.dart';

void main() {
  group('Game', () {
    test('when instantiated then returns unstarted game', () {
      final game = defaultGame();

      expect(game.isStarted, false);
      expect(game.isGameLost, false);
      expect(game.isPaused, false);
      expect(game.score, 0);
      expect(game.foodPosition, null);
      expect(game.direction, null);
      expect(game.snakeBody, []);
    });

    group('.start()', () {
      test('when called then starts game and initializes objects', () {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;

        game.start(xBoundary, yBoundary);

        expectStartCondition(xBoundary, yBoundary, game);
      });
    });

    group('.loop()', () {
      test(
          'when game is not started then do nothing and return need to start result',
          () {
        final game = defaultGame();

        final result = game.loop();

        expect(result, LoopResult.needStartBefore);
      });

      test(
          'when snake moves into empty cell then update snake and return ok result',
          () {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);

        final initialSnakeBody = game.snakeBody;
        final result = game.loop();

        expect(result, LoopResult.ok);
        expect(game.snakeBody, isNot(initialSnakeBody));
      });

      test(
          'when snake moves out of bound then game is lost and return need to stop result',
          () {
        final game = defaultGame();
        final xBoundary = 3.0;
        final yBoundary = 3.0;
        game.start(xBoundary, yBoundary);

        game.loop();
        final result = game.loop();

        expect(result, LoopResult.needStop);
        expect(game.isGameLost, true);
      });

      test(
          'when snake eats food then add score, add period, and return need to refresh result',
          () {
        final game = GameState(
          getRandomPosition: (_, __) => Position(left: 50, top: 49),
          getRandomDirection: () => Direction.up,
        );
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);

        final result = game.loop();

        expect(result, LoopResult.needRefresh);
        expect(game.score, 1);
        expect(game.period, 215);
      });

      test('when snake commits suicide then game is lost and return need to stop result', () {
        final game = GameState(
          initialSnakeSize: 5,
          getRandomPosition: (_, __) => Position(left: 1, top: 1),
          getRandomDirection: () => Direction.up,
        );
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);

        game.loop();
        
        game.turn(Direction.left);
        game.loop();

        game.turn(Direction.down);
        game.loop();

        game.turn(Direction.right);
        final result = game.loop();
        
        expect(result, LoopResult.needStop);
        expect(game.isGameLost, true);
      });
    });

    group('.restart()', () {
      test('when game is already started then run restart', () {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);
        game.loop();

        game.restart();

        expectStartCondition(xBoundary, yBoundary, game);
      });

      test('when game is not started then do nothing', () {
        final game = defaultGame();

        game.restart();

        expect(game.isStarted, false);
      });

    });

    group('.turn()', () {
      test(
          'when given non-opposite direction from the current then set the new direction on the next loop',
          () async {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);

        game.turn(Direction.right);
        game.loop();

        expect(game.direction, Direction.right);
      });

      test(
          'when given opposite direction from the current then set previous direction on the next loop',
          () async {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);

        game.loop();
        final previousDirection = game.direction;

        game.turn(Direction.down);
        game.loop();

        expect(game.direction, previousDirection);
      });
    });   

    group('.pause()', () {  
      test('when called then pauses the game', () {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);

        game.pause();

        expect(game.isPaused, true);
      });
    });

    group('.resume()', () {
      test('when called then resumes the paused game', () {
        final game = defaultGame();
        final xBoundary = 100.0;
        final yBoundary = 100.0;
        game.start(xBoundary, yBoundary);
        game.pause();

        game.resume();

        expect(game.isPaused, false);
      });
    });

  });
}

void expectStartCondition(double xBoundary, double yBoundary, GameState game) {
  expect(game.isStarted, true);
  expect(game.isGameLost, false);
  expect(game.isPaused, false);
  expect(game.score, 0);
  expect(game.foodPosition, isNotNull);
  expect(game.foodPosition!.left, lessThan(xBoundary));
  expect(game.foodPosition!.top, lessThan(yBoundary));
  expect(game.direction, isNotNull);
  expect(game.snakeBody, isNotEmpty);
  game.snakeBody.forEach((segment) {
    expect(segment.left, lessThan(xBoundary));
    expect(segment.top, lessThan(yBoundary));
  });
}

GameState defaultGame() {
  return GameState(
    getRandomPosition: (int _, int __) => Position(left: 1, top: 1),
    getRandomDirection: () => Direction.up,
  );
}
