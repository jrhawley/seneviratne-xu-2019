# Summary

Date Received: 2019-01-11
Sequencing ID: D00165_0253_ACCVKJANXX

This folder contains the raw sequencing data for the same samples as before (`../Processed/atac_dnase/`), but using the Omni-ATAC protocol instead of the original one.
The previous dataset had good sequencing quality but had a low peak:background ratio (low percentages of reads in peaks).
Hopefully this data looks better.

## Data Description

The samples are single-end, 50bp sequenced.
See HTML reports in `Reports/` for details.

## Results

### Duplication rates

Base calls are high quality, but sequence duplication levels are very high (~ 41-54%).
This is a bit concerning, but each sample has > 75M reads total, so I'll be left with 35-50M reads after deduplication.

## Called peaks
