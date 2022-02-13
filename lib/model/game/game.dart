import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:tiny_snake/model/game/i_game.dart';

import '../direction.dart';
import '../food.dart';
import '../position.dart';
import '../snake.dart';

typedef GetRandomPosition = Position Function(int, int);
typedef GetRandomDirection = Direction Function();

class Game extends ChangeNotifier implements IGame {
  static const int DefaultUnitSize = 10;
  static const int DefaultInitialSnakeSize = 4;
  static const int DefaultInitialLoopDuration = 250;

  late final int unitSize;
  late final int initialSnakeSize;
  late final int initialLoopDuration;
  late final GetRandomPosition getRandomPosition;
  late final GetRandomDirection getRandomDirection;

  IGameState state;

  Game({
    required this.state,
    required this.getRandomPosition,
    required this.getRandomDirection,
    int? unitSize,
    int? initialSnakeSize,
    int? initialLoopDuration,
  })  : unitSize = unitSize ?? DefaultUnitSize,
        initialSnakeSize = initialSnakeSize ?? DefaultInitialSnakeSize,
        initialLoopDuration = initialLoopDuration ?? DefaultInitialLoopDuration;

  @override
  int get period {
    final modifier = 50;
    return initialLoopDuration - (modifier * log(state.score + 1)).round();
  }

  @override
  void next(IGameAction action) {
    state = state.next(this, action);

    if (!(action is Turn)) {
      notifyListeners();
    }
  }

  @override
  Food generateFood(int xBoundary, int yBoundary) {
    return Food(
      weight: 1,
      position: getRandomPosition(xBoundary, yBoundary),
    );
  }

  @override
  Snake generateSnake(int xBoundary, int yBoundary, int length) {
    return Snake.create(
      initialPosition: Position(
        left: (xBoundary / 2).floor(),
        top: (yBoundary / 2).floor(),
      ),
      length: length,
    );
  }

  @override
  void listen(VoidCallback listener) {
    addListener(listener);
  }

  @override
  String toString() {
    return 'Game(period: $period, unitSize: $unitSize, initialSnakeSize: $initialSnakeSize, initialLoopDuration: $initialLoopDuration, state: $state)';
  }
}

class NotStarted implements IGameState {
  @override
  int get score => 0;

  @override
  Position? get foodPosition => null;

  @override
  List<Position> get snakePosition => [];

  @override
  IGameState next(covariant Game game, IGameAction action) {
    if (action is Start) {
      final xBoundary = action.xBoundary.floor();
      final yBoundary = action.yBoundary.floor();

      return Playing.initial(xBoundary, yBoundary, game);
    }

    return this;
  }
}

class Playing implements IGameState {
  late final int xBoundary;
  late final int yBoundary;
  late final Snake snake;
  late final Direction currentDirection;
  late final Food food;
  late final int score;
  late final ListQueue<Direction> directionBuffer;

  Playing({
    required this.xBoundary,
    required this.yBoundary,
    required this.snake,
    required this.currentDirection,
    required this.food,
    required this.score,
    required this.directionBuffer,
  });

  static Playing initial(int xBoundary, int yBoundary, Game game) {
    return Playing(
      xBoundary: xBoundary,
      yBoundary: yBoundary,
      currentDirection: game.getRandomDirection(),
      food: game.generateFood(xBoundary, yBoundary),
      snake: game.generateSnake(xBoundary, yBoundary, game.initialSnakeSize),
      directionBuffer: ListQueue.of([]),
      score: 0,
    );
  }

  @override
  Position? get foodPosition => food.position;

  @override
  List<Position> get snakePosition => snake.body;

  @override
  IGameState next(IGame game, IGameAction action) {
    if (action is Loop) {
      final newDirectionFromBuffer = directionBuffer.isNotEmpty
          ? directionBuffer.removeLast()
          : currentDirection;
      final nextDirection = newDirectionFromBuffer.isOpposite(currentDirection)
          ? currentDirection
          : newDirectionFromBuffer;
      final moveResult = snake.move(nextDirection);

      if (moveResult.state == MoveState.suicide) {
        return _gameOver(GameOverReason.suicide);
      }

      if (_isSnakeOutOfBound(moveResult.nextSnake)) {
        return _gameOver(GameOverReason.outOfBound);
      }

      if (_isSnakeEating(moveResult.nextSnake)) {
        final grownSnake = moveResult.nextSnake.grow(food.weight);
        return copyWith(
          score: score + 1,
          snake: grownSnake,
          currentDirection: nextDirection,
          food: game.generateFood(xBoundary, yBoundary),
        );
      }

      return copyWith(
        snake: moveResult.nextSnake,
        currentDirection: nextDirection,
      );
    }

    if (action is Turn) {
      return copyWith(
        directionBuffer: directionBuffer..addFirst(action.direction),
      );
    }

    if (action is Pause) {
      return Pausing(this);
    }

    return this;
  }

  GameOver _gameOver(GameOverReason reason) {
    return GameOver(
      xBoundary: xBoundary,
      yBoundary: yBoundary,
      snake: snake,
      food: food,
      score: score,
      reason: reason,
    );
  }

  bool _isSnakeOutOfBound(Snake snake) {
    return snake.body.any(
      (segment) =>
          segment.left < 0 ||
          segment.top < 0 ||
          segment.left >= xBoundary ||
          segment.top >= yBoundary,
    );
  }

  bool _isSnakeEating(Snake snake) {
    return snake.head == food.position;
  }

  Playing copyWith({
    int? xBoundary,
    int? yBoundary,
    Snake? snake,
    Direction? currentDirection,
    Food? food,
    int? score,
    ListQueue<Direction>? directionBuffer,
  }) {
    return Playing(
      xBoundary: xBoundary ?? this.xBoundary,
      yBoundary: yBoundary ?? this.yBoundary,
      snake: snake ?? this.snake,
      currentDirection: currentDirection ?? this.currentDirection,
      food: food ?? this.food,
      score: score ?? this.score,
      directionBuffer: directionBuffer ?? this.directionBuffer,
    );
  }

  @override
  String toString() {
    return 'Playing(xBoundary: $xBoundary, yBoundary: $yBoundary, snake: $snake, currentDirection: $currentDirection, food: $food, score: $score, directionBuffer: $directionBuffer)';
  }
}

class GameOver implements IGameState {
  late final int xBoundary;
  late final int yBoundary;
  late final Snake snake;
  late final Food food;
  late final int score;
  late final GameOverReason reason;

  GameOver({
    required this.xBoundary,
    required this.yBoundary,
    required this.snake,
    required this.food,
    required this.score,
    required this.reason,
  });

  @override
  Position? get foodPosition => food.position;

  @override
  List<Position> get snakePosition => snake.body;

  @override
  IGameState next(covariant Game game, IGameAction action) {
    if (action is Restart) {
      return Playing.initial(xBoundary, yBoundary, game);
    }

    return this;
  }

  @override
  String toString() {
    return 'GameOver(xBoundary: $xBoundary, yBoundary: $yBoundary, snake: $snake, food: $food, score: $score, reason: $reason)';
  }
}

class Pausing implements IGameState {
  late final Playing previousState;

  Pausing(this.previousState);

  @override
  Position? get foodPosition => previousState.food.position;

  @override
  List<Position> get snakePosition => previousState.snake.body;

  @override
  IGameState next(IGame game, IGameAction action) {
    if (action is Resume) {
      return previousState;
    }

    return this;
  }

  @override
  int get score => previousState.score;

  @override
  String toString() => 'Pausing(previousState: $previousState)';
}

enum GameOverReason { outOfBound, suicide }

class Start implements IGameAction {
  final double xBoundary;
  final double yBoundary;

  const Start(this.xBoundary, this.yBoundary);
}

class Loop implements IGameAction {
  const Loop();
}

class Restart implements IGameAction {
  const Restart();
}

class Turn implements IGameAction {
  final Direction direction;

  const Turn(this.direction);
}

class Pause implements IGameAction {
  const Pause();
}

class Resume implements IGameAction {
  const Resume();
}
