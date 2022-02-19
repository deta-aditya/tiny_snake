part of super_food;

class IsNotSpawing extends ISuperFoodState {
  @override
  Position? get position => null;
}

class IsSpawning extends ISuperFoodState {
  final Food food;
  final int ageLeft;

  IsSpawning({
    required this.food,
    required this.ageLeft,
  });

  @override
  Position? get position => food.position;

  @override
  String toString() => 'IsSpawning(food: $food, ageLeft: $ageLeft)';
}

class IsGone extends ISuperFoodState {
  final int eatCount;

  IsGone(this.eatCount);

  @override
  Position? get position => null;

  @override
  String toString() => 'IsGone(eatCount: $eatCount)';
}
