# GLP-1-Based Therapies, CNS Depressants and Aspiration / Gastrointestinal Motility: Analysis Code and Results

The model-stage software is released under the **MIT License**; the two original, derived result CSVs are released under **CC BY 4.0**. See `RIGHTS.md` for precise per-file licensing and third-party exclusions. Cite a Zenodo DOI only after the corresponding archive record exists.

This repository documents **independent model replays** associated with a three-system pharmacovigilance analysis using FAERS/AERS, JADER and Canada Vigilance. The current files allow verification of the **model-fitting stage** when the correct grouped inputs are available under suitable access permissions.

**Scope:** 42 standard grouped-binomial logistic models and 13 mean-bias-reduced grouped-binomial logistic models. Historical no-estimate results (12 rows) are reported but are not refitted.

**Important limitation:** This code package **does not** contain the source-level data preparation, drug/outcome mapping, numerator/denominator construction, or all upstream ETL scripts required to regenerate the complete study from the regulatory data feeds. It must not be described as end-to-end replication of the full study.

## Contents

- `scripts/replay_standard_models.R` — re-estimates 42 standard grouped-binomial models.
- `scripts/replay_bias_reduced_models.R` — re-estimates 13 bias-reduced product interaction models using `brglm2::brglmFit`, `type = "AS_mean"`.
- `results/model_estimates.csv` — frozen database-level model estimates and historical no-estimate status (without source-case or quarterly counts).
- `results/model_replay_comparison.csv` — comparison of 55 newly replayed estimates against the archived model estimates.
- `docs/input_schema.md` — exact expected input fields and file names.
- `docs/data_access.md` — dataset and disclosure limitations.
- `docs/validation.md` — numeric validation and interpretive scope.
- `environment/software.md` — known historical package versions.

## Model replay

The scripts require four **separately held** frozen CSV inputs (one model-estimate reference and three quarterly grouped model-input tables). Those files are **not included** because the grouped tables include small counts and have not been approved for public redistribution. They are not interchangeable with raw official download files.

In RStudio, open each script, set the optional `INPUT_DIR_OVERRIDE` to the directory containing the four source files, or leave it blank and select `175H_stage6M_database_specific_estimates.csv` when prompted. Source the full script (do not execute one line at a time). The input files are checked against their archived MD5 hashes and sizes before fitting.

Because the grouped inputs are not distributed, an independent reader **cannot directly rerun the 55 historical model estimates solely from this repository**. Model formulas and results can be reviewed; reproducing numeric estimates requires lawful access to matching inputs or generation of suitably authorized source inputs.

The scripts are **new independent replay implementations**, not the original historical Stage6M or Stage6N source code. Analyses were carried out separately by database; results must not be interpreted as individual-level pooling.

## Rights and attribution

Third-party data, clinical dictionaries and trademarks remain under their respective conditions. The identified software creator is **Chengxiang Huang** (affiliation and ORCID in `CITATION.cff`), and the declared software rights holder is **Chengxiang Huang**. The original repository software is licensed under **MIT** (`LICENSE`); the two derived result CSVs are separately licensed under **CC BY 4.0** (`LICENSE-DATA-CC-BY-4.0.md`). The license terms are scoped by file in `RIGHTS.md`. Do not redistribute the withheld grouped inputs, report-level files, proprietary coding dictionaries, or historical workstation archives with this repository.

## Lightweight aggregate checks (no controlled data needed)

Run `python scripts/verify_aggregate_tables.py` using Python 3 (standard library only) to check the included aggregate tables. An equivalent R check is supplied at `scripts/verify_published_results.R` for users with R installed. These are **table-consistency checks, not model re-estimation**.

Read `docs/reproducibility_scope.md`, `docs/upstream_code_scope.md` and `docs/data_access.md` for the exact scope and access restrictions. The model-stage software rights holder has selected MIT for software and CC BY 4.0 for the two derived result tables. Mixed-license Zenodo metadata still must be verified on the actual archive record. See `docs/source_data_attribution.md`, `docs/source_data_attribution.md`, and `CITATION.cff`.

## Detailed provenance and release boundary

See `docs/workflow.md` and `docs/workflow_coverage.csv` for an explicit step-by-step account of which upstream stages have preserved sources, which have only frozen outcomes, and which remain missing. Historical preprocessing scripts are not included; no portable end-to-end pipeline from the official source data has been validated. The code is provided under MIT and creator metadata is recorded. Any actual Zenodo deposit must represent both MIT (software) and CC BY 4.0 (two derived CSVs) accurately.

## Regulatory attribution and sharing status

This repository credits software creator **Chengxiang Huang** (Department of Anesthesiology, Foshan Hospital of Traditional Chinese Medicine; complete author affiliation and ORCID in `CITATION.cff`). Official FDA, PMDA/JADER and Health Canada licensing requirements were checked for the two aggregate result files. Model estimates and replay comparisons contain no report-level data or quarterly event-count cells, and are included as separately licensed, derived result tables; their separate CC BY 4.0 reuse terms must be represented correctly on any published archive record. See `docs/source_data_attribution.md` and `docs/source_data_attribution.md`.

**License map: software = MIT; the two derived result CSVs = CC BY 4.0. Verify that Zenodo metadata reflects both rights; do not let auto-detection silently mislabel the mixed archive.**
