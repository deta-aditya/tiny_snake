part of randomizer;

abstract class IDoubleRandomizer {
  factory IDoubleRandomizer.determined(double doubleValue) =>
      _DeterminedDouble(doubleValue);

  double nextDouble();
}