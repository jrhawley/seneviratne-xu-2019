# Running Log

## 2018-10-31

I've finished the first pass of this data following the same steps that I performed in `2018-10-10_global-accessibility/`.

## 2018-11-02

After consulting with Aditi, she said that she's surprised the samples aren't clustering together well.
I should try and come up with a different consensus set based on the set of sites that are shared across a condition.
From these condition-specific sites, merge them to form a new consensus.
Then calculate Jaccard indices and Upset plots.

## 2018-11-05

After I've removed the duplicate peak calls from `--call-summits` in MACS2, I've re-run the global comparisons of peak counts and bp counts.
I've also updated the figure and added a `Snakefile`.