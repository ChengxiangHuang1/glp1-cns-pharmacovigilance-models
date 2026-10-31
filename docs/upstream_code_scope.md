# Upstream code scope and provenance

This repository contains two **new independent R replay implementations** for the final grouped-binomial model stage, plus archived non-restricted estimates and replay comparisons. It does **not** contain the full historical preprocessing code or regenerate the study from regulatory data downloads.

## Source-code recovery versus executable release

The researchers recovered 24 named historical R source files for internal provenance review. **Twenty-four recovered source files does not mean every executable step of the study has been recovered.** These files are withheld from this repository because they retain historical local paths, run-specific directories, dependencies on restricted report-level objects, or preliminary/superseded versions. They have not been converted into a validated, portable end-to-end workflow.

| Segment | Historical source material | Reproducibility boundary |
| --- | --- | --- |
| FAERS/AERS | Quarterly checkpointing, 23/17/32-column model construction, formal estimation and warning review sources recovered | Requires independently obtained and normalized quarterly data, historical checkpoint/mapping artifacts and authorization for relevant dictionaries; full upstream pipeline not independently rerun |
| JADER and Canada Vigilance | Case-level outcome-flag source and Stage6D v1.11 linkage source recovered | Frozen drug and outcome mapping provenance exists, but upstream normalization/dictionary generation code and source inputs are not supplied |
| Stage6M | Historical final-model code candidate and archived results exist | Exact executed source-byte identity is not established for every stage; new replay scripts faithfully re-estimated final estimates from identical frozen grouped inputs |
| Demographics | Source locator, source audit, linkage, report-level summary and date/sex correction scripts recovered | Data-specific local inputs and corrected coding sequence are not supplied as an executable, clean-room pipeline |
| Independent replay | 42 standard and 13 bias-reduced grouped-binomial estimates rerun on a Windows R 4.6.0 research computer | All 55 estimates agree with the frozen Stage6M results within stated thresholds, conditional on exact frozen grouped inputs |

## What a third party can do

- Inspect model formulas, released estimates and archived replay comparisons.
- Run `scripts/verify_published_results.R` to check integrity of the two released aggregate result files without controlled input data.
- Independently run 55 model fits with `scripts/replay_standard_models.R` and `scripts/replay_bias_reduced_models.R` **only after lawful access** to the same four previously frozen CSV inputs. All four input files are matched to frozen MD5 values and byte lengths before fitting.

## What this package cannot substantiate

It cannot demonstrate independent re-extraction, deduplication, drug-term matching, comparison-group construction, outcome-flag construction, reference mapping, age/sex coding, or PT analyses directly from FDA/PMDA/Health Canada raw files. Historical validation reports are not substitutes for a second end-to-end execution. No historical source-code snapshots, raw records, case-level files, small-cell grouped inputs, licensed terminology lists or authors' local file paths are bundled here.
