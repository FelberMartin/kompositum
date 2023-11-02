import 'dart:math';

List<T> randomSampleWithoutReplacement<T>(List<T> inputList, int sampleSize, {Random? random}) {
  random ??= Random();
  final List<T> sample = [];
  final List<T> copyList = List.from(inputList);

  for (int i = 0; i < sampleSize && copyList.isNotEmpty; i++) {
    final randomIndex = random.nextInt(copyList.length);
    sample.add(copyList.removeAt(randomIndex));
  }

  return sample;
}