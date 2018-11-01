# Summary

Following up from `2018-10-10_global-accessibility/` using the re-preprocessed data and filtered peak lists from `2018-10-31_filtered-peaks/`.

## Results

### Controls tend to have less accessible chromatin, but it is not statistically significant

To see whether there are differences in global accessibility between each of the 3 conditions, we can count the number of peaks from each sample, as well as the total number of base pairs contained within peaks.

![Base pairs in peaks per sample](bp.png)
![Number of peaks per sample](peaks.png)

We see that using both metrics, the Control case tends to have the least accessible chromatin, whereas the TAZ knockdowns tend to have more.

None of the conditions are significantly different from each other (2 sample permutation test, see `plot-global-acc.R`).
The results of the tests are as follows:

| X       | Y     | Data  | Hypothesis | _p_   | _FDR_ |
| ------- | ----- | ----- | ---------- | ----- | ----- |
| Control | 1stKD | BP    | X >= Y     | 0.100 | 0.300 |
| Control | 2ndKD | BP    | X >= Y     | 0.581 | 0.581 |
| 1stKD   | 2ndKD | BP    | X = Y      | 0.200 | 0.300 |
| Control | 1stKD | Peaks | X >= Y     | 0.033 | 0.100 |
| Control | 2ndKD | Peaks | X >= Y     | 0.403 | 0.403 |
| 1stKD   | 2ndKD | Peaks | X = Y      | 0.133 | 0.200 |

As before, none of the associations are significant, although there's a trend towards more open chromatin in the TAZ knockdowns.

### Peak overlap between conditions
