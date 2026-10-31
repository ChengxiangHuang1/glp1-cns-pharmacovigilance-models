# Changelog

## 1.0.0 — 2026-10-31

First public software-and-results release of the model-stage reproducibility subset for the three-regulator pharmacovigilance study.

- R implementations for 42 standard and 13 mean-bias-reduced grouped-binomial model replays; exact archived grouped inputs are required to re-estimate the historical coefficients.
- 67 archived model/status records and 55 independent numerical replay comparisons.
- Lightweight R and Python checks of the distributed summary tables that do not require restricted inputs.
- Original software is MIT-licensed; the two derived results CSVs are CC BY 4.0-licensed.
- Report-level datasets, small-count quarterly grouped inputs, historical workstation files, and third-party terminology dictionaries are not distributed.

The versioned release does **not** provide an end-to-end reconstruction pipeline from the three regulatory raw sources. The numerical validations were previously performed on the frozen historical model-stage inputs. No new statistical fitting was introduced by release packaging.
