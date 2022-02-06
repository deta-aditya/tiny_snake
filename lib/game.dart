import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/game_state.dart';
import 'model/direction.dart';
import 'model/position.dart';

class Game extends StatelessWidget {
  const Game({Key? key, bool? isDebugMode})
      : this.isDebugMode = isDebugMode ?? false,
        super(key: key);

  final bool isDebugMode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      builder: (context, child) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Consumer<GameState>(
                    builder: (context, game, child) {
                      return Text(
                        'Score: ${game.score}',
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final game = context.watch<GameState>();
                      final xBoundary =
                          constraints.maxWidth / GameState.UnitSize;
                      final yBoundary =
                          constraints.maxHeight / GameState.UnitSize;

                      if (!game.isStarted) {
                        game.start(xBoundary, yBoundary);
                      }

                      return Stack(
                        children: [
                          GameBoundary(
                            xBoundary: xBoundary,
                            yBoundary: yBoundary,
                          ),
                          if (game.isStarted)
                            FoodView(position: game.foodPosition!),
                          ...renderSnake(game.snakeBody),
                          if (game.isGameLost) GameOverOverlay(),
                          if (isDebugMode) DebugOverlay(),
                        ],
                      );
                    },
                  ),
                ),
                ControlBar(
                  onChange: (Direction newDir) {
                    context.read<GameState>().turn(newDir);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GameBoundary extends StatelessWidget {
  const GameBoundary({
    Key? key,
    required this.xBoundary,
    required this.yBoundary,
  }) : super(key: key);

  final double xBoundary;
  final double yBoundary;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      right: (xBoundary - xBoundary.floor()) * GameState.UnitSize,
      bottom: (yBoundary - yBoundary.floor()) * GameState.UnitSize,
      child: Container(
        color: Colors.grey.shade200,
      ),
    );
  }
}

class DebugOverlay extends StatelessWidget {
  const DebugOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: Consumer<GameState>(
        builder: (context, game, child) {
          return Text(game.toString());
        },
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over',
              style: const TextStyle(
                fontSize: 36,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                context.read<GameState>().restart();
              },
              child: const Text('Play Again'),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
              ),
            )
          ],
        ),
        color: Colors.red.withOpacity(0.7),
      ),
    );
  }
}

class FoodView extends StatelessWidget {
  const FoodView({
    Key? key,
    required this.position,
  }) : super(key: key);

  final Position position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.top.toDouble() * GameState.UnitSize,
      left: position.left.toDouble() * GameState.UnitSize,
      child: Container(
        width: GameState.UnitSize.toDouble(),
        height: GameState.UnitSize.toDouble(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GameState.UnitSize.toDouble()),
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}

class ControlBar extends StatelessWidget {
  const ControlBar({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  final void Function(Direction) onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DirectionButton(
            direction: Direction.left,
            text: '←',
          ),
          Column(
            children: [
              DirectionButton(
                direction: Direction.up,
                text: '↑',
              ),
              DirectionButton(
                direction: Direction.down,
                text: '↓',
              ),
            ],
          ),
          DirectionButton(
            direction: Direction.right,
            text: '→',
          ),
        ],
      ),
    );
  }
}

class DirectionButton extends StatelessWidget {
  const DirectionButton({
    Key? key,
    required this.direction,
    required this.text,
  }) : super(key: key);

  final Direction direction;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<GameState>().turn(direction);
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
    );
  }
}

List<Widget> renderSnake(List<Position> snakeBody) {
  return snakeBody
      .map((position) => SnakeBodyView(
            left: position.left.toDouble(),
            top: position.top.toDouble(),
          ))
      .toList();
}

enum SnakeBodyPart { head, middle, tail }

class SnakeBodyView extends StatelessWidget {
  const SnakeBodyView({
    Key? key,
    required this.left,
    required this.top,
    SnakeBodyPart? part,
  })  : this.part = part ?? SnakeBodyPart.middle,
        super(key: key);

  final double left;
  final double top;
  final SnakeBodyPart part;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top * GameState.UnitSize,
      left: left * GameState.UnitSize,
      child: Container(
        width: GameState.UnitSize.toDouble(),
        height: GameState.UnitSize.toDouble(),
        color: Colors.blue,
      ),
    );
  }
}
