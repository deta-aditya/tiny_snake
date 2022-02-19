part of super_food;

class _SpawnSuperFoodOnce implements ISuperFoodSpawnStrategy {
  final int age;
  final int weight;

  bool hasSpawned = false;

  _SpawnSuperFoodOnce(
    this.age,
    this.weight,
  );

  @override
  ISuperFoodAction shouldSpawnSuperFood(int eatCount) {
    if (hasSpawned) {
      return DontSpawn();
    }

    hasSpawned = true;
    return Spawn(
      weight: weight,
      age: age,
    );
  }
}
