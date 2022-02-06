import 'dart:math';

enum Direction { up, right, down, left }

extension DirectionMethods on Direction {
  bool isOpposite(Direction against) {
    return (this == Direction.up && against == Direction.down) ||
        (this == Direction.down && against == Direction.up) ||
        (this == Direction.left && against == Direction.right) ||
        (this == Direction.right && against == Direction.left);
  }
}

Direction randomDirection() {
  final rng = Random();
  final allDirections = Direction.values;

  return allDirections[rng.nextInt(allDirections.length)];
}
