import 'direction.dart';
import 'position.dart';

class Snake {
  Snake({required this.body, required this.length});

  final List<Position> body;
  final int length;

  Snake.create({
    required Position initialPosition,
    required int length,
  })  : length = length,
        body = [initialPosition];

  Position get head {
    return body.first;
  }

  Snake copyWith({
    List<Position>? body,
    int? length,
  }) {
    return Snake(
      body: body ?? this.body,
      length: length ?? this.length,
    );
  }

  Snake move(Direction direction) {
    final newBody = [_newBodySegment(direction, body.first), ...body];

    if (body.length < length) {
      return copyWith(
        body: newBody,
      );
    }

    return copyWith(body: newBody..removeLast());
  }

  Snake grow(int addition) {
    return copyWith(length: length + addition);
  }

  Position _newBodySegment(Direction direction, Position prev) {
    switch (direction) {
      case Direction.up:
        return prev.copyWith(top: prev.top - 1);
      case Direction.right:
        return prev.copyWith(left: prev.left + 1);
      case Direction.down:
        return prev.copyWith(top: prev.top + 1);
      case Direction.left:
        return prev.copyWith(left: prev.left - 1);
    }
  }
}
