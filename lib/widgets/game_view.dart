import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/direction.dart';
import '../model/game/game.dart';
import '../model/game_loop.dart';
import '../model/position.dart';

class GameView extends StatefulWidget {
  const GameView({Key? key, bool? isDebugMode})
      : this.isDebugMode = isDebugMode ?? false,
        super(key: key);

  final bool isDebugMode;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late GameLoop loop;
  late Game game;

  @override
  void initState() {
    super.initState();
    game = Game(
      state: NotStarted(),
      getRandomPosition: Position.random,
      getRandomDirection: randomDirection,
    );
    loop = GameLoop(game);
  }

  @override
  void dispose() {
    loop.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game,
      builder: (context, child) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Consumer<Game>(
                    builder: (context, game, child) {
                      return Text(
                        'Score: ${game.state.score}',
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final game = context.watch<Game>();
                      final xBoundary = constraints.maxWidth / game.unitSize;
                      final yBoundary = constraints.maxHeight / game.unitSize;

                      // Run when widget is finished rendering
                      WidgetsBinding.instance
                          ?.addPostFrameCallback((timeStamp) {
                        if (game.state is NotStarted) {
                          game.next(Start(xBoundary, yBoundary));
                        }
                      });

                      return Stack(
                        children: [
                          GameBoundary(
                            xBoundary: xBoundary,
                            yBoundary: yBoundary,
                            unitSize: game.unitSize,
                          ),
                          if (game.state.foodPosition != null)
                            FoodView(
                              position: game.state.foodPosition!,
                              unitSize: game.unitSize,
                            ),
                          ...renderSnake(
                            game.state.snakePosition,
                            game.unitSize,
                          ),
                          if (game.state is Pausing) PauseOverlay(),
                          if (game.state is GameOver) GameOverOverlay(),
                          if (widget.isDebugMode) DebugOverlay(),
                        ],
                      );
                    },
                  ),
                ),
                const ControlBar(),
              ],
            ),
            floatingActionButton: Consumer<Game>(
              builder: (context, game, child) {
                if (game.state is Pausing) {
                  return AbortButton();
                }
                if (!(game.state is GameOver)) {
                  return PauseButton();
                }
                return Container();
              },
            ),
          ),
        );
      },
    );
  }
}

class PauseButton extends StatelessWidget {
  const PauseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.pause),
      mini: true,
      onPressed: () {
        context.read<Game>().next(Pause());
      },
    );
  }
}

class AbortButton extends StatelessWidget {
  const AbortButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.close),
      backgroundColor: Colors.red,
      mini: true,
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        child: Container(
          color: Colors.white.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Paused',
                style: const TextStyle(
                  fontSize: 36,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Press anywhere to resume',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        onTap: () => context.read<Game>().next(Resume()),
      ),
    );
  }
}

class GameBoundary extends StatelessWidget {
  const GameBoundary({
    Key? key,
    required this.xBoundary,
    required this.yBoundary,
    required this.unitSize,
  }) : super(key: key);

  final double xBoundary;
  final double yBoundary;
  final int unitSize;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      right: (xBoundary - xBoundary.floor()) * unitSize,
      bottom: (yBoundary - yBoundary.floor()) * unitSize,
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
      child: Consumer<Game>(
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
                context.read<Game>().next(Restart());
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
    required this.unitSize,
  }) : super(key: key);

  final Position position;
  final int unitSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.top.toDouble() * unitSize,
      left: position.left.toDouble() * unitSize,
      child: Container(
        width: unitSize.toDouble(),
        height: unitSize.toDouble(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(unitSize.toDouble()),
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}

class ControlBar extends StatelessWidget {
  const ControlBar({
    Key? key,
  }) : super(key: key);

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
    return Consumer<Game>(
      builder: (context, game, child) {
        return ElevatedButton(
          onPressed:
              game.state is Playing ? () => game.next(Turn(direction)) : null,
          child: Text(text),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
        );
      },
    );
  }
}

List<Widget> renderSnake(List<Position> snakeBody, int unitSize) {
  return snakeBody
      .map((position) => SnakeBodyView(
            left: position.left.toDouble(),
            top: position.top.toDouble(),
            unitSize: unitSize,
          ))
      .toList();
}

enum SnakeBodyPart { head, middle, tail }

class SnakeBodyView extends StatelessWidget {
  const SnakeBodyView({
    Key? key,
    SnakeBodyPart? part,
    required this.left,
    required this.top,
    required this.unitSize,
  })  : this.part = part ?? SnakeBodyPart.middle,
        super(key: key);

  final double left;
  final double top;
  final SnakeBodyPart part;
  final int unitSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top * unitSize,
      left: left * unitSize,
      child: Container(
        width: unitSize.toDouble(),
        height: unitSize.toDouble(),
        color: Colors.blue,
      ),
    );
  }
}
