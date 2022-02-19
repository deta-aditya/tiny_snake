part of super_food;

abstract class ISuperFoodSpawnStrategy {
  factory ISuperFoodSpawnStrategy.never() {
    return _NeverSpawnSuperFood();
  }

  factory ISuperFoodSpawnStrategy.always(int weight) {
    return _AlwaysSpawnSuperFood(weight);
  }

  factory ISuperFoodSpawnStrategy.once(int age, int weight) {
    return _SpawnSuperFoodOnce(age, weight);
  }

  factory ISuperFoodSpawnStrategy.byChance({
    required IDoubleRandomizer doubleRandomizer,
    required int weight,
    required double chance,
    required int age,
  }) {
    return _SpawnSuperFoodByChance(
      doubleRandomizer: doubleRandomizer,
      weight: weight,
      chance: chance,
      age: age,
    );
  }

  ISuperFoodAction shouldSpawnSuperFood(int eatCount);
}

abstract class ISuperFoodAction {}

abstract class SuperFoodState {
  Position? get position;
}
