part of randomizer;

class _DeterminedDouble implements IDoubleRandomizer {
  final double doubleValue;

  _DeterminedDouble(this.doubleValue);

  @override
  double nextDouble() {
    return doubleValue;
  }
}
