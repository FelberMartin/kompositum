import 'dart:math';

import 'package:kompositum/util/extensions/random_util.dart';
import 'package:test/test.dart';

void main() {
  group("randomSampleWithoutReplacement", () {
    test(
      "should return an empty list if the input list is empty",
      () {
        final sample = randomSampleWithoutReplacement([], 1);
        expect(sample, []);
      },
    );

    test(
      "should return an empty list if the sample size is 0",
      () {
        final sample = randomSampleWithoutReplacement([1, 2, 3], 0);
        expect(sample, []);
      },
    );

    test(
      "should return the input list if the sample size is equal to the input list size",
      () {
        final sample = randomSampleWithoutReplacement([1, 2, 3], 3);
        expect(sample, containsAll([1, 2, 3]));
      },
    );

    test(
      "should return a different samples for mulitple executions",
      () {
        final samples = [];
        for (var i = 0; i < 20; i++) {
          samples.add(randomSampleWithoutReplacement([1, 2, 3], 1).first);
        }
        expect(samples, containsAll([1, 2, 3]));
      },
    );

    test(
      "should return the same sample for multiple calls with the same seed",
      () {
        final samples = [];
        for (int i = 0; i < 20; i++) {
          samples.add(randomSampleWithoutReplacement([1, 2, 3], 1, random: Random(1)).first);
        }
        expect(samples.toSet().length, 1);
      });
  });
}