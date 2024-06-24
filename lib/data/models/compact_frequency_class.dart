enum CompactFrequencyClass {
  easy(12),
  medium(15),
  hard(18);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}