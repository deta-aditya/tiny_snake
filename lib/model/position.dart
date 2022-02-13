import 'dart:math';

class Position {
  Position({required this.left, required this.top});

  late final int left;
  late final int top;

  Position copyWith({
    int? left,
    int? top,
  }) {
    return Position(
      left: left ?? this.left,
      top: top ?? this.top,
    );
  }

  Position.random(int xMax, int yMax) {
    final rng = Random();
    this.left = rng.nextInt(xMax);
    this.top = rng.nextInt(yMax);
  }

  Position.origin()
      : left = 0,
        top = 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Position && other.left == left && other.top == top;
  }

  @override
  int get hashCode => left.hashCode ^ top.hashCode;

  @override
  String toString() => 'Position(left: $left, top: $top)';
}
