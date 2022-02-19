part of super_food;

class _SpawnSuperFoodByChance implements ISuperFoodSpawnStrategy {
  final IDoubleRandomizer doubleRandomizer;
  final int weight;
  final double chance;
  final int age;
  
  _SpawnSuperFoodByChance({
    required this.doubleRandomizer,
    required this.weight,
    required this.chance,
    required this.age,
  });

  @override
  ISuperFoodAction shouldSpawnSuperFood(int eatCount) {
    if (eatCount > 0 &&
        doubleRandomizer.nextDouble() < chance) {
      return Spawn(
        weight: weight,
        age: age,
      );
    }
    return DontSpawn();
  }
}
