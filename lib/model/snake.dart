import 'direction.dart';
import 'position.dart';

class Snake {
  Snake._({required this.body, required this.length});

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
    return Snake._(
      body: body ?? this.body,
      length: length ?? this.length,
    );
  }

  MoveResult move(Direction direction) {
    final newBody = [_newBodySegment(direction, body.first), ...body];

    if (_isMovingContradictorily(newBody)) {
      return MoveResult(MoveState.contradictory, copyWith());
    }

    if (_isCommittingSuicide(newBody)) {
      return MoveResult(MoveState.suicide, copyWith());
    }

    if (body.length < length) {
      return MoveResult(MoveState.success, copyWith(body: newBody));
    }

    return MoveResult(MoveState.success, copyWith(body: newBody..removeLast()));
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

  bool _isMovingContradictorily(List<Position> body) {
    return body.length >= 3 && body.first == body[2];
  }

  bool _isCommittingSuicide(List<Position> body) {
    final uniquePositions = Set<Position>();
    return body.any((segment) => !uniquePositions.add(segment));
  }
}

enum MoveState {
  success,
  contradictory,
  suicide,
}

class MoveResult {
  final MoveState state;
  final Snake nextSnake;

  MoveResult(this.state, this.nextSnake);
}
