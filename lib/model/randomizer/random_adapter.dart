part of randomizer;

class RandomAdapter implements IDoubleRandomizer {
  final Random random;

  RandomAdapter(this.random);

  @override
  double nextDouble() {
    return random.nextDouble();
  }
}
