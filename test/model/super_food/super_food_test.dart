import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_snake/model/randomizer/randomizer.dart';
import 'package:tiny_snake/model/super_food/super_food.dart';

void main() {
  group('SuperFood', () {
    group('.byChance()', () {
      test('given eat count is zero then return don\'t spawn', () {
        final strategy = ISuperFoodSpawnStrategy.byChance(
          doubleRandomizer: IDoubleRandomizer.determined(1.0),
          weight: 2,
          chance: 0.5,
          age: 10,
        );

        final result = strategy.shouldSpawnSuperFood(0);

        expect(result, isA<DontSpawn>());
      });

      test('given chance is not less than returned random number then return don\'t spawn', () {
        final strategy = ISuperFoodSpawnStrategy.byChance(
          doubleRandomizer: IDoubleRandomizer.determined(1.0),
          weight: 2,
          chance: 0.5,
          age: 10,
        );

        final result = strategy.shouldSpawnSuperFood(2);

        expect(result, isA<DontSpawn>());
      });

      test('given all condition is fulfilled then return spawn', () {
        final strategy = ISuperFoodSpawnStrategy.byChance(
          doubleRandomizer: IDoubleRandomizer.determined(0.0),
          weight: 2,
          chance: 0.5,
          age: 10,
        );

        final result = strategy.shouldSpawnSuperFood(2);

        expect(result, isA<Spawn>());
        expect((result as Spawn).weight, 2);
        expect(result.age, 10);
      });
    });
  });
}
