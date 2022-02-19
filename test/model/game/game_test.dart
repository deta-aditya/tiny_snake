import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_snake/model/direction.dart';
import 'package:tiny_snake/model/food.dart';
import 'package:tiny_snake/model/game/game.dart';
import 'package:tiny_snake/model/position.dart';
import 'package:tiny_snake/model/snake.dart';
import 'package:tiny_snake/model/super_food/super_food.dart';

void main() {
  group('Game', () {
    const defaultXBoundary = 100.0;
    const defaultYBoundary = 100.0;

    final defaultGetRandomPosition =
        (int _, int __) => Position(left: 1, top: 1);
    final defaultGetRandomDirection = () => Direction.up;

    group('.next(Start)', () {
      test('when game is not started then start the game', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );

        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        expect(game.state, isA<Playing>());
        expect(game.state.score, 0);
        expect(game.period, Game.DefaultInitialLoopDuration);
      });
    });

    group('.next(Loop)', () {
      test('when game is not started then do nothing', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );

        game.next(const Loop());

        expect(game.state, isA<NotStarted>());
      });

      test('when snake moves into empty cell then update snake', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        final prevState = game.state as Playing;
        final prevSnake = prevState.snake;
        game.next(const Loop());

        expect(game.state, isA<Playing>());
        expect((game.state as Playing).snake.body, isNot(prevSnake.body));
      });

      test('when snake moves out of bound then game is over', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(3.0, 3.0));

        game.next(const Loop());
        game.next(const Loop());

        expect(game.state, isA<GameOver>());
        expect((game.state as GameOver).reason, GameOverReason.outOfBound);
      });

      test('when snake eats food then add score, grow snake, and change period',
          () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: (_, __) => Position(left: 50, top: 49),
          getRandomDirection: () => Direction.up,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        game.next(const Loop());

        final expectedSnakeLength = Game.DefaultInitialSnakeSize + 1;
        expect(game.state, isA<Playing>());
        expect(game.state.score, 1);
        expect((game.state as Playing).snake.length, expectedSnakeLength);
        expect(game.period, 215);
      });

      test(
          'given game can spawn super food, when condition is fulfilled then spawn super food',
          () {
        final determinedPosition = Position(left: 50, top: 49);
        final game = Game(
          state: NotStarted(),
          getRandomPosition: (_, __) => determinedPosition,
          getRandomDirection: defaultGetRandomDirection,
          superFoodSpawnStrategy: ISuperFoodSpawnStrategy.always(5),
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        game.next(const Loop());

        expect(game.state, isA<Playing>());
        expect((game.state as Playing).superFoodState, isA<IsSpawning>());
      });

      test(
          'given has spawned super food, when age is passed then remove super food',
          () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
          superFoodSpawnStrategy: ISuperFoodSpawnStrategy.once(2, 2),
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        game.next(const Loop());
        
        // Super food should spawn here
        game.next(const Loop());
        game.next(const Loop());

        // Super food should expire here
        game.next(const Loop());

        expect(game.state, isA<Playing>());
        expect((game.state as Playing).superFoodState, isA<IsNotSpawing>());
      });
    });

    group('.next(Restart)', () {
      test('when game is not over then do nothing', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );

        game.next(const Restart());

        expect(game.state, isA<NotStarted>());
      });

      test('when game is over then restart the game', () {
        final game = Game(
          state: GameOver(
            score: 5,
            eatCount: 5,
            xBoundary: defaultXBoundary.floor(),
            yBoundary: defaultYBoundary.floor(),
            reason: GameOverReason.outOfBound,
            food: Food(position: Position(left: 1, top: 1), weight: 1),
            snake: Snake.create(
              initialPosition: Position(left: 10, top: 10),
              length: 4,
            ),
          ),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );

        game.next(const Restart());

        expect(game.state, isA<Playing>());
        expect(game.state.score, 0);
        expect(game.period, Game.DefaultInitialLoopDuration);
      });
    });

    group('.next(Turn)', () {
      test('when game is not playing then do nothing', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );

        game.next(const Turn(Direction.up));

        expect(game.state, isA<NotStarted>());
      });

      test(
          'when given non-opposite direction from the current then set the new direction on the next loop',
          () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        game.next(const Turn(Direction.right));
        game.next(const Loop());

        expect(game.state, isA<Playing>());
        expect((game.state as Playing).currentDirection, Direction.right);
      });

      test(
          'when given opposite direction from the current then set the current direction on the next loop',
          () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));
        final previousDirection = (game.state as Playing).currentDirection;

        game.next(const Turn(Direction.down));
        game.next(const Loop());

        expect(game.state, isA<Playing>());
        expect((game.state as Playing).currentDirection, previousDirection);
      });

      test(
          'when given directions that leads to snake committing suicide then game is lost',
          () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        game.next(const Loop());

        game.next(const Turn(Direction.left));
        game.next(const Loop());

        game.next(const Turn(Direction.down));
        game.next(const Loop());

        game.next(const Turn(Direction.right));
        game.next(const Loop());

        expect(game.state, isA<GameOver>());
        expect((game.state as GameOver).reason, GameOverReason.suicide);
      });
    });

    group('.next(Pause)', () {
      test('when called then pauses the game', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));

        game.next(const Pause());

        expect(game.state, isA<Pausing>());
      });
    });

    group('.next(Resume)', () {
      test('when called then resume the game', () {
        final game = Game(
          state: NotStarted(),
          getRandomPosition: defaultGetRandomPosition,
          getRandomDirection: defaultGetRandomDirection,
        );
        game.next(const Start(
          defaultXBoundary,
          defaultYBoundary,
        ));
        game.next(const Pause());

        game.next(const Resume());

        expect(game.state, isA<Playing>());
      });
    });
  });
}
