enum CompactFrequencyClass {
  easy(13),
  medium(16),
  hard(20);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}