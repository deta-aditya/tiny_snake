import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:tiny_snake/model/game/i_game.dart';
import 'package:tiny_snake/model/super_food/super_food.dart';

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
  late final ISuperFoodSpawnStrategy superFoodSpawnStrategy;

  IGameState state;

  Game({
    required this.state,
    required this.getRandomPosition,
    required this.getRandomDirection,
    int? unitSize,
    int? initialSnakeSize,
    int? initialLoopDuration,
    ISuperFoodSpawnStrategy? superFoodSpawnStrategy,
  })  : unitSize = unitSize ?? DefaultUnitSize,
        initialSnakeSize = initialSnakeSize ?? DefaultInitialSnakeSize,
        initialLoopDuration = initialLoopDuration ?? DefaultInitialLoopDuration,
        superFoodSpawnStrategy =
            superFoodSpawnStrategy ?? ISuperFoodSpawnStrategy.never();

  @override
  int get period {
    final modifier = 50;
    return initialLoopDuration - (modifier * log(state.eatCount + 1)).round();
  }

  @override
  void next(IGameAction action) {
    state = state.next(this, action);

    if (!(action is Turn)) {
      notifyListeners();
    }
  }

  @override
  Food generateFood(int xBoundary, int yBoundary, int weight) {
    return Food(
      weight: weight,
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
  int get eatCount => 0;

  @override
  Position? get foodPosition => null;

  @override
  Position? get superFoodPosition => null;

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
  late final int eatCount;
  late final SuperFoodState superFoodState;
  late final ListQueue<Direction> directionBuffer;

  Playing({
    required this.xBoundary,
    required this.yBoundary,
    required this.snake,
    required this.currentDirection,
    required this.food,
    required this.score,
    required this.eatCount,
    required this.superFoodState,
    required this.directionBuffer,
  });

  factory Playing.initial(int xBoundary, int yBoundary, Game game) {
    return Playing(
      xBoundary: xBoundary,
      yBoundary: yBoundary,
      currentDirection: game.getRandomDirection(),
      food: game.generateFood(xBoundary, yBoundary, 1),
      snake: game.generateSnake(xBoundary, yBoundary, game.initialSnakeSize),
      directionBuffer: ListQueue.of([]),
      score: 0,
      eatCount: 0,
      superFoodState: IsNotSpawing(),
    );
  }

  @override
  Position? get foodPosition => food.position;

  @override
  Position? get superFoodPosition => superFoodState.position;

  @override
  List<Position> get snakePosition => snake.body;

  @override
  IGameState next(covariant Game game, IGameAction action) {
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

      final eatenFood = _isSnakeEating(moveResult.nextSnake);

      if (eatenFood != null) {
        final grownSnake = moveResult.nextSnake.grow(eatenFood.weight);
        return copyWith(
          score: score + eatenFood.weight,
          eatCount: eatCount + 1,
          snake: grownSnake,
          currentDirection: nextDirection,
          food: eatenFood == food
              ? game.generateFood(xBoundary, yBoundary, 1)
              : food,
          superFoodInfo: _handleSuperFoodSpawn(eatenFood, eatCount + 1, game),
        );
      }

      return copyWith(
        snake: moveResult.nextSnake,
        currentDirection: nextDirection,
        superFoodInfo: _handleSuperFoodSpawn(eatenFood, eatCount, game),
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
      eatCount: eatCount,
      superFood: superFoodState is IsSpawning
          ? (superFoodState as IsSpawning).food
          : null,
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

  Food? _isSnakeEating(Snake snake) {
    if (snake.head == foodPosition) {
      return food;
    }

    if (snake.head == superFoodPosition) {
      return (superFoodState as IsSpawning).food;
    }

    return null;
  }

  SuperFoodState _handleSuperFoodSpawn(Food? currentlyEatenFood, int eatCount, Game game) {
    if (superFoodState is IsGone && (superFoodState as IsGone).eatCount < eatCount) {
      return IsNotSpawing();
    }

    if (superFoodState is IsSpawning) {
      final info = superFoodState as IsSpawning;

      if (info.food == currentlyEatenFood || info.ageLeft == 0) {
        return IsGone(eatCount);
      }

      return IsSpawning(food: info.food, ageLeft: info.ageLeft - 1);
    }

    if (superFoodState is IsNotSpawing && currentlyEatenFood != null) {
      final result = game.superFoodSpawnStrategy.shouldSpawnSuperFood(eatCount);

      if (result is Spawn) {
        return IsSpawning(
          food: game.generateFood(xBoundary, yBoundary, result.weight),
          ageLeft: result.age,
        );
      }
    }

    return superFoodState;
  }

  Playing copyWith({
    int? xBoundary,
    int? yBoundary,
    Snake? snake,
    Direction? currentDirection,
    Food? food,
    int? score,
    int? eatCount,
    SuperFoodState? superFoodInfo,
    ListQueue<Direction>? directionBuffer,
  }) {
    return Playing(
      xBoundary: xBoundary ?? this.xBoundary,
      yBoundary: yBoundary ?? this.yBoundary,
      snake: snake ?? this.snake,
      currentDirection: currentDirection ?? this.currentDirection,
      food: food ?? this.food,
      score: score ?? this.score,
      eatCount: eatCount ?? this.eatCount,
      superFoodState: superFoodInfo ?? this.superFoodState,
      directionBuffer: directionBuffer ?? this.directionBuffer,
    );
  }

  @override
  String toString() {
    return 'Playing(xBoundary: $xBoundary, yBoundary: $yBoundary, snake: $snake, currentDirection: $currentDirection, food: $food, score: $score, eatCount: $eatCount, superFoodState: $superFoodState, directionBuffer: $directionBuffer)';
  }
}

class GameOver implements IGameState {
  late final int xBoundary;
  late final int yBoundary;
  late final Snake snake;
  late final Food food;
  late final int score;
  late final int eatCount;
  late final Food? superFood;
  late final GameOverReason reason;

  GameOver({
    required this.xBoundary,
    required this.yBoundary,
    required this.snake,
    required this.food,
    required this.score,
    required this.reason,
    required this.eatCount,
    this.superFood,
  });

  @override
  Position? get foodPosition => food.position;

  @override
  Position? get superFoodPosition => superFood?.position;

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
  int get eatCount => previousState.eatCount;

  @override
  Position? get superFoodPosition => previousState.superFoodPosition;

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
