import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_snake/model/direction.dart';
import 'package:tiny_snake/model/position.dart';
import 'package:tiny_snake/model/snake.dart';

void main() {
  final defaultPosition = Position(left: 1, top: 1);
  final defaultLength = 4;

  group('Snake', () {
    group('.create()', () {
      test('when called then length is set and inital position is set on body',
          () async {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength,
        );

        expect(snake.length, defaultLength);
        expect(snake.body, contains(defaultPosition));
      });
    });

    group('.move()', () {
      test('when body is smaller than length then body grows', () {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength,
        );

        final moveResult = snake.move(Direction.up);

        expect(moveResult.state, MoveState.success);
        expect(
          moveResult.nextSnake.body,
          [
            Position(left: 1, top: 0),
            Position(left: 1, top: 1),
          ],
        );
      });

      test('when body is the same as length then body pops and pushes itself',
          () {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength,
        );

        final result = List.generate(5, (x) => x).fold(
          MoveResult(MoveState.success, snake),
          (MoveResult previousValue, _) =>
              previousValue.nextSnake.move(Direction.down),
        );

        expect(result.state, MoveState.success);
        expect(
          result.nextSnake.body,
          [
            Position(left: 1, top: 6),
            Position(left: 1, top: 5),
            Position(left: 1, top: 4),
            Position(left: 1, top: 3),
          ],
        );
      });

      test('when given different directions then move accordingly', () {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength,
        );
        final directions = [
          Direction.down,
          Direction.down,
          Direction.right,
          Direction.up,
          Direction.right,
        ];

        final result = directions.fold(
          MoveResult(MoveState.success, snake),
          (MoveResult previousValue, direction) =>
              previousValue.nextSnake.move(direction),
        );

        expect(result.state, MoveState.success);
        expect(
          result.nextSnake.body,
          containsAll([
            Position(left: 3, top: 2),
            Position(left: 2, top: 2),
            Position(left: 2, top: 3),
            Position(left: 1, top: 3),
          ]),
        );
      });

      test(
          'when given opposite directions next to each other then return contradictory result',
          () {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength,
        );
        final directions = [
          Direction.down,
          Direction.up,
        ];

        final result = directions.fold(
          MoveResult(MoveState.success, snake),
          (MoveResult previousValue, direction) =>
              previousValue.nextSnake.move(direction),
        );

        expect(result.state, MoveState.contradictory);
      });

      test('when body overlaps then return suicide result', () {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength + 1,
        );
        final directions = [
          Direction.down,
          Direction.right,
          Direction.up,
          Direction.left,
        ];

        final result = directions.fold(
          MoveResult(MoveState.success, snake),
          (MoveResult previousValue, direction) =>
              previousValue.nextSnake.move(direction),
        );

        expect(result.state, MoveState.suicide);
      });
    });

    group('.grow()', () {
      test('when called then extends snake length', () {
        final snake = Snake.create(
          initialPosition: defaultPosition,
          length: defaultLength,
        );

        final newSnake = snake.grow(1);

        expect(newSnake.length, defaultLength + 1);
      });
    });
  });
}
