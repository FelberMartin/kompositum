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

T randomElement<T>(List<T> elements, {Random? random}) {
  random ??= Random();
  final randomIndex = random.nextInt(elements.length);
  return elements[randomIndex];
}

T randomWeightedElement<T>(Map<T, double> elementsWithWeights, {Random? random}) {
  random ??= Random();
  final totalWeight = elementsWithWeights.values.reduce((a, b) => a + b);
  final randomValue = random.nextDouble() * totalWeight;

  double currentWeight = 0;
  for (final entry in elementsWithWeights.entries) {
    currentWeight += entry.value;
    if (randomValue <= currentWeight) {
      return entry.key;
    }
  }

  throw Exception("This should never happen");
}

List<T> randomWeightedElementsWithoutReplacement<T>(
    Map<T, double> elementsWithWeights, int sampleSize, {Random? random}) {
  random ??= Random();
  final List<T> sample = [];
  final Map<T, double> copyMap = Map.from(elementsWithWeights);

  for (int i = 0; i < sampleSize && copyMap.isNotEmpty; i++) {
    final element = randomWeightedElement(copyMap, random: random);
    sample.add(element);
    copyMap.remove(element);
  }

  return sample;
}