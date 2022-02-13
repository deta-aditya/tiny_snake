import 'position.dart';

class Food {
  Food({
    required this.position,
    required this.weight,
  });

  final Position position;
  final int weight;

  @override
  String toString() => 'Food(position: $position, weight: $weight)';
}
