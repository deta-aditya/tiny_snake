import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../model/direction.dart';
import '../model/food.dart';
import '../model/position.dart';
import '../model/snake.dart';

class GameState extends ChangeNotifier {
  static const int UnitSize = 10;
  static const int InitialSnakeSize = 4;
  static const int InitialLoopDuration = 250;

  Snake? _snake;
  Direction? _direction;
  Food? _food;

  int? _xBoundary;
  int? _yBoundary;
  Timer? _timer;

  bool _isGameLost = false;

  final ListQueue<Direction> _commandQueue = ListQueue.of([]);

  int get score => _snake != null ? _snake!.length - InitialSnakeSize : 0;

  bool get isStarted => !(_snake == null ||
      _direction == null ||
      _food == null ||
      _xBoundary == null ||
      _yBoundary == null ||
      _timer == null);

  List<Position> get snakeBody => _snake?.body ?? [];

  Position? get foodPosition => _food?.position;

  bool get isGameLost => _isGameLost;

  void start(double xBoundary, double yBoundary) {
    _xBoundary = xBoundary.floor();
    _yBoundary = yBoundary.floor();

    _direction = randomDirection();

    _snake = Snake.create(
      length: InitialSnakeSize,
      initialPosition: Position(
        // Render the snake in the middle. Later this needs to be changed
        // to random with padding
        left: (_xBoundary! / 2).floor(),
        top: (_yBoundary! / 2).floor(),
      ),
    );

    _food = _generateFood();
    _timer = _generateTimer();
    _isGameLost = false;

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

  void stop() {
    _timer?.cancel();
    notifyListeners();
  }

  void _gameLoop(Timer timer) {
    if (_commandQueue.isNotEmpty) {
      final newDirection = _commandQueue.removeLast();

      if (!newDirection.isOpposite(_direction!)) {
        _direction = newDirection;
      }
    }

    final newSnake = _snake!.move(_direction!);

    if (_isSnakeOutOfBound(newSnake) || _isSnakeSuicide(newSnake)) {
      timer.cancel();
      _isGameLost = true;
      notifyListeners();
      return;
    }

    if (newSnake.head == _food!.position) {
      _snake = newSnake.grow(_food!.weight);
      _food = _generateFood();
      timer.cancel();
      _timer = _generateTimer();
    } else {
      _snake = newSnake;
    }

    notifyListeners();
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

  bool _isSnakeSuicide(Snake snake) {
    final uniquePositions = Set<Position>();

    return snake.body.any((segment) => !uniquePositions.add(segment));
  }

  Food _generateFood() {
    return Food(
      weight: 1,
      // Later add padding for each boundaries
      position: Position.random(
        xMax: _xBoundary!,
        yMax: _yBoundary!,
      ),
    );
  }

  Timer _generateTimer() {
    final modifier = (50 * log(score + 1)).round();

    return Timer.periodic(
      Duration(milliseconds: InitialLoopDuration - modifier),
      _gameLoop,
    );
  }

  @override
  String toString() {
    return 'Snake = ${_snake?.body.toString() ?? ''}, Boundary = ($_xBoundary, $_yBoundary)';
  }
}
