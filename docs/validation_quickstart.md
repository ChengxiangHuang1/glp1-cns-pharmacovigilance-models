# Re-run instructions and validation levels

## A. Results-table integrity (publicly runnable; no research input files)

From the repository root, either command checks the included aggregate tables (the Python check was run against the released summary tables; the public R table-checker was not separately executed here):

```sh
python scripts/verify_aggregate_tables.py
```

```sh
Rscript scripts/verify_published_results.R
```

This checks 67 frozen result rows, 55 numerical replay comparisons, the 42/13/12 method partition, and pairwise agreement using `database + analysis_id + method` keys. It **does not fit models**.

## B. Model-stage numerical replay (requires separately held and authorized files)

Put the four correctly frozen CSVs in a private local directory. The exact filenames, byte sizes and MD5 digests are recorded in `docs/input_schema.md`. From RStudio, `source("scripts/replay_standard_models.R")` and `source("scripts/replay_bias_reduced_models.R")`; when prompted, select the 175H reference CSV from the same directory. Or set the `INPUT_DIR_OVERRIDE` variable near the top of each script.

Both scripts first validate the input identities; the standard replay fits 42 models and the mean-bias-reduced replay fits 13 models using R 4.6.0 with `brglm2` 1.1.0 for the latter. The historical 12 non-estimates are preserved, not force-fitted. Calculations are database-specific and not individual-level pooled.

## C. Upstream end-to-end regeneration (not demonstrated)

The repository contains neither source-specific normalized data nor a verified executable pipeline from official regulatory downloads through 175G production. Reproduction claims must be limited to levels A and (for authorized holders of the required frozen inputs) B.

### Software

Use a compatible R environment; the historical Windows 11 analysis used R 4.6.0, `brglm2` 1.1.0, `data.table` 1.18.4, `Matrix` 1.7-5 and `digest` 0.6.39. This package does not install packages or require running another script before verifying the published aggregate result tables.
