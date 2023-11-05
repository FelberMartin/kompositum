enum CompactFrequencyClass {
  easy(12),
  medium(16),
  hard(20);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}