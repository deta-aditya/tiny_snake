part of super_food;

class Spawn extends ISuperFoodAction {
  final int weight;
  final int age;
  
  Spawn({
    required this.weight,
    required this.age,
  });
}

class DontSpawn extends ISuperFoodAction {}
