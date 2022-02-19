part of super_food;

class _NeverSpawnSuperFood implements ISuperFoodSpawnStrategy {
  @override
  ISuperFoodAction shouldSpawnSuperFood(int eatCount) {
    return DontSpawn();
  }
}

class _AlwaysSpawnSuperFood implements ISuperFoodSpawnStrategy {
  final int weight;

  _AlwaysSpawnSuperFood(this.weight);
  
  @override
  ISuperFoodAction shouldSpawnSuperFood(int eatCount) {
    return Spawn(weight: weight, age: 99);
  }
}
