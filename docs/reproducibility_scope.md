# Reproducibility scope

Two distinct checks are possible with the materials in this repository.

**Aggregate consistency, no restricted inputs:** `python scripts/verify_aggregate_tables.py` checks the integrity of 67 database-specific model/status rows and 55 archived numerical replay comparisons. It does not fit models.

**Model-stage re-estimation with permitted inputs:** the two R scripts refit 42 standard and 13 mean-bias-reduced grouped-binomial models. They require four separately held, byte-identical 175H/175G CSVs. The three 175G files are not redistributed because they contain low-count quarterly cells and require a separate disclosure and permissions assessment. The scripts reject substitutes whose hashes or sizes differ from the archived reference.

The 12 historical no-estimate records are preserved, not refitted. None of the supplied files regenerate the complete regulatory-source preprocessing, drug dictionaries, comparison-group construction, denominator construction, demographic transformations, or term-level analyses. Accordingly this is a **model-stage reproducibility subset**, not an end-to-end rerunnable study.

The two model-replay R scripts were run and numerically verified on a Windows R 4.6.0 research workstation using the original frozen grouped inputs. The public copy of the light R table checker has not been separately executed in this environment. The Python table checker was executed as part of the release review using only the included aggregate tables.
