import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_snake/model/direction.dart';

void main() {
  group('Direction', () {
    group('.isOpposite()', () {
      test('when given opposite direction then return true', () {
        final oppositionMap = {
          Direction.up: Direction.down,
          Direction.left: Direction.right,
          Direction.down: Direction.up,
          Direction.right: Direction.left
        };

        oppositionMap.forEach((key, value) {
          final isOpposite = key.isOpposite(value);
          expect(isOpposite, true);
        });
      });
    });
  });
}