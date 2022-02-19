part of super_food;

class IsNotSpawing extends SuperFoodState {
  @override
  Position? get position => null;
}

class IsSpawning extends SuperFoodState {
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

class IsGone extends SuperFoodState {
  final int eatCount;

  IsGone(this.eatCount);

  @override
  Position? get position => null;

  @override
  String toString() => 'IsGone(eatCount: $eatCount)';
}
