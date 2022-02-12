import 'dart:collection';
import 'dart:math';

import '../model/direction.dart';
import '../model/food.dart';
import '../model/game/i_game.dart';
import '../model/position.dart';
import '../model/snake.dart';

typedef GetRandomPosition = Position Function(int, int);
typedef GetRandomDirection = Direction Function();

class GameState extends IGame {
  static const int UnitSize = 10;
  static const int InitialSnakeSize = 4;
  static const int InitialLoopDuration = 250;

  final ListQueue<Direction> _commandQueue = ListQueue.of([]);
  late final int _initialSnakeSize;
  late final GetRandomPosition _getRandomPosition;
  late final GetRandomDirection _getRandomDirection;

  Snake? _snake;
  Direction? _direction;
  Food? _food;

  int? _xBoundary;
  int? _yBoundary;

  bool _isPaused = false;
  bool _isGameLost = false;

  GameState({
    int? initialSnakeSize,
    required GetRandomPosition getRandomPosition,
    required GetRandomDirection getRandomDirection,
  })  : _initialSnakeSize = initialSnakeSize ?? InitialSnakeSize,
        _getRandomPosition = getRandomPosition,
        _getRandomDirection = getRandomDirection;

  int get score => _snake != null ? _snake!.length - InitialSnakeSize : 0;

  bool get isStarted => !(_snake == null ||
      _direction == null ||
      _food == null ||
      _xBoundary == null ||
      _yBoundary == null);

  List<Position> get snakeBody => _snake?.body ?? [];

  Position? get foodPosition => _food?.position;

  bool get isGameLost => _isGameLost;

  bool get isPaused => _isPaused && !_isGameLost;

  int get period => InitialLoopDuration - (50 * log(score + 1)).round();

  Direction? get direction => _direction;

  void start(double xBoundary, double yBoundary) {
    _xBoundary = xBoundary.floor();
    _yBoundary = yBoundary.floor();

    _direction = _getRandomDirection();

    _snake = Snake.create(
      length: _initialSnakeSize,
      initialPosition: Position(
        // Render the snake in the middle. Later this needs to be changed
        // to random with padding
        left: (_xBoundary! / 2).floor(),
        top: (_yBoundary! / 2).floor(),
      ),
    );

    _food = _generateFood();
    _isGameLost = false;

    _commandQueue.clear();

    notifyListeners();
  }

  void restart() {
    if (isStarted) {
      start(_xBoundary!.toDouble(), _yBoundary!.toDouble());
    }
  }

  void turn(Direction direction) {
    _commandQueue.addFirst(direction);
  }

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    notifyListeners();
  }

  void stop() {
    notifyListeners();
  }

  LoopResult loop() {
    if (!isStarted) {
      return LoopResult.needStartBefore;
    }

    final result = () {
      var newDirection =
          _commandQueue.isNotEmpty ? _commandQueue.removeLast() : _direction!;
      final result = _moveSnake(newDirection, _snake!);

      late Snake newSnake;
      if (result is _ResultSuccess) {
        newDirection = result.supposedDirection;
        newSnake = result.nextSnake;
      } else if (result is _ResultSuicide) {
        _isGameLost = true;
        return LoopResult.needStop;
      }

      if (_isSnakeOutOfBound(newSnake)) {
        _isGameLost = true;
        return LoopResult.needStop;
      }

      _direction = newDirection;
      if (newSnake.head == _food!.position) {
        _snake = newSnake.grow(_food!.weight);
        _food = _generateFood();
        return LoopResult.needRefresh;
      }

      _snake = newSnake;
      return LoopResult.ok;
    }();

    notifyListeners();
    return result;
  }

  _GameMoveSnakeResult _moveSnake(Direction newDirection, Snake newSnake) {
    final moveResult = _snake!.move(newDirection);

    switch (moveResult.state) {
      case MoveState.success:
        return _ResultSuccess(newDirection, moveResult.nextSnake);
      case MoveState.contradictory:
        return _moveSnake(_direction!, newSnake);
      case MoveState.suicide:
        return _ResultSuicide();
    }
  }

  bool _isSnakeOutOfBound(Snake snake) {
    return snake.body.any(
      (segment) =>
          segment.left < 0 ||
          segment.top < 0 ||
          segment.left >= _xBoundary! ||
          segment.top >= _yBoundary!,
    );
  }

  Food _generateFood() {
    return Food(
      weight: 1,
      // Later add padding for each boundaries
      position: _getRandomPosition(_xBoundary!, _yBoundary!),
    );
  }

  @override
  String toString() {
    return 'Snake = ${_snake?.body.toString() ?? ''}, Boundary = ($_xBoundary, $_yBoundary)';
  }
}

abstract class _GameMoveSnakeResult {}

class _ResultSuccess extends _GameMoveSnakeResult {
  final Direction supposedDirection;
  final Snake nextSnake;

  _ResultSuccess(this.supposedDirection, this.nextSnake);
}

class _ResultSuicide extends _GameMoveSnakeResult {}
