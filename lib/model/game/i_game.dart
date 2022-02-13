import 'package:flutter/foundation.dart';

import '../food.dart';
import '../position.dart';
import '../snake.dart';

abstract class IGame {
  IGameState get state;
  int get period;
  void listen(VoidCallback listener);
  void next(IGameAction action);
  Food generateFood(int xBoundary, int yBoundary);
  Snake generateSnake(int xBoundary, int yBoundary, int length);
}

abstract class IGameState {
  IGameState next(IGame game, IGameAction action);
  Position? get foodPosition;
  List<Position> get snakePosition;
  int get score;
}

abstract class IGameAction {}
