# Analysis workflow and reproducibility scope

This repository contains model-stage code and selected summary results. The project followed distinct FAERS/AERS, JADER and Canada Vigilance preprocessing branches; **no individual case records were pooled across systems**.

## Main branches

1. **FAERS/AERS:** regulator reports → report deduplication/normalization → 89-quarter compact drug tables → comparative flags and 32-column model-ready input → grouped model inputs. Only historical portions of the latter stages have been recovered; the archive does **not** establish a fully executable raw-feed preprocessing path.
2. **JADER and Canada Vigilance:** source-specific normalization → drug/outcome dictionary mapping → case-level outcome flags (Stage6C3) → drug/outcome linkage (Stage6D) → grouped inputs. The complete dictionary-construction and raw-source normalization programs are not included.
3. **Final model layer:** Stage6M generated database-specific grouped model inputs and 67 result records (42 standard, 13 bias-reduced, 12 not estimated). The 55 estimable results have since been independently rerun in R against the frozen grouped tables.
4. **Descriptive demographic layer:** separate report-level summaries and a subsequent date/sex QC correction; full raw-input recreation is not supplied in this code package.

The accompanying `workflow_coverage.csv` lists each known stage and its evidence boundary. These descriptions document research history; they are not executable instructions to reconstruct controlled data.

## Code release and verification

- `scripts/replay_standard_models.R`: independently validates 42 standard fitted models **only when the four original frozen grouped-input CSV files are available**.
- `scripts/replay_bias_reduced_models.R`: similarly validates 13 bias-reduced models.
- `scripts/verify_published_results.R`: checks the released model estimates and replay comparisons without obtaining those withheld inputs. **It does not refit statistical models**.

These model-replay scripts are newly implemented and do not represent copies of historical Stage6N source. They have been compared against frozen Stage6M results in a Windows R environment, but the R release files have not separately undergone a full cross-platform execution test after documentation changes. The released Python summary checker was verified against the included aggregate tables.

**Do not call this an end-to-end reproducibility package.** Required source-normalization scripts, mappings, record-level input files and quarter-level small-count tables are not redistributed.
