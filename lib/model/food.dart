import 'package:equatable/equatable.dart';

import 'position.dart';

class Food extends Equatable {
  Food({
    required this.position,
    required this.weight,
  });

  final Position position;
  final int weight;

  @override
  String toString() => 'Food(position: $position, weight: $weight)';

  @override
  List<Object?> get props => [position, weight];
}
