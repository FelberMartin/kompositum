enum CompactFrequencyClass {
  easy(28),
  medium(33),
  hard(37);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}

/*
  Statistics on the frequency classes:
    16.0         1
    17.0         3
    18.0        10
    19.0        25
    20.0        46
    21.0        74
    22.0       116
    23.0       181
    24.0       290
    25.0       480
    26.0       774
    27.0      1208
    28.0      1913
    29.0      2929
    30.0      4310
    31.0      6125
    32.0      8638
    33.0     12003
    34.0     15909
    35.0     20760
    36.0     26425
    37.0     32534
    38.0     38901
    39.0     44850
    40.0     50484
    41.0     56741
    42.0     65115
    43.0     75884
    44.0     87579
    45.0     95816
    46.0    102722
 */