# Summary

In this folder, I'm attempting to filter the peaks according to a few metrics to see if I can make the lists more stringent for each sample.
Previous analyses in the other `Results/` folders were a bit strange and seemed to be coming from the noise in off-peak reads and in the called peaks themselves.

I'm attempting to address this by doing a couple things:

1. Find the trade-off between q-value and number of peaks
2. Find the percentage of non-peak reads (i.e. noise)

## Results

### q-value vs Peak Counts

![q-value vs peaks](q-threshold_vs_peak-counts.png)

Using a q-value cutoff of -log10(q) > 2.5 (i.e. q <~ 0.003) returns between 20-50% of peaks with p < 0.01.
For a variety of thresholds, here are the peak counts:

#### q <= 0.1 (-log10(q) >= 1)

| Condition | Replicate | N      |
| --------- | --------- | ------ |
| 1stKD     | 1         | 117909 |
| 1stKD     | 2         | 141996 |
| 2ndKD     | 1         | 49215  |
| 2ndKD     | 2         | 91942  |
| 2ndKD     | 3         | 103708 |
| Ctrl      | 1         | 85752  |
| Ctrl      | 2         | 52970  |
| Ctrl      | 3         | 69682  |

#### q <= 0.01 (-log10(q) >= 2)

| Condition | Replicate | N     |
| --------- | --------- | ----- |
| 1stKD     | 1         | 86752 |
| 1stKD     | 2         | 98908 |
| 2ndKD     | 1         | 22258 |
| 2ndKD     | 2         | 60912 |
| 2ndKD     | 3         | 56766 |
| Ctrl      | 1         | 56128 |
| Ctrl      | 2         | 29871 |
| Ctrl      | 3         | 41225 |

#### q <~ 0.003 (-log10(q) >= 2.5)

| Condition | Replicate | N     |
| --------- | --------- | ----- |
| 1stKD     | 1         | 71492 |
| 1stKD     | 2         | 81956 |
| 2ndKD     | 1         | 17807 |
| 2ndKD     | 2         | 48520 |
| 2ndKD     | 3         | 45668 |
| Ctrl      | 1         | 45077 |
| Ctrl      | 2         | 23358 |
| Ctrl      | 3         | 35189 |

#### q <= 0.001 (-log10(q) >= 3)

| Condition | Replicate | N     |
| --------- | --------- | ----- |
| 1stKD     | 1         | 63617 |
| 1stKD     | 2         | 74254 |
| 2ndKD     | 1         | 13981 |
| 2ndKD     | 2         | 40017 |
| 2ndKD     | 3         | 39886 |
| Ctrl      | 1         | 37507 |
| Ctrl      | 2         | 19309 |
| Ctrl      | 3         | 29300 |

#### q <= 0.0001 (-log10(q) >= 4)

| Condition | Replicate | N     |
| --------- | --------- | ----- |
| 1stKD     | 1         | 47020 |
| 1stKD     | 2         | 57409 |
| 2ndKD     | 1         | 9669  |
| 2ndKD     | 2         | 30940 |
| 2ndKD     | 3         | 29567 |
| Ctrl      | 1         | 29078 |
| Ctrl      | 2         | 14569 |
| Ctrl      | 3         | 22475 |
