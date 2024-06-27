enum CompactFrequencyClass {
  easy(28),
  medium(33),
  hard(37);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}