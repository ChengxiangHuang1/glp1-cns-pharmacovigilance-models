# Data access and permitted distribution

Source pharmacovigilance records were obtained through the official sources of the US Food and Drug Administration (FAERS/AERS), the Japanese Pharmaceuticals and Medical Devices Agency (JADER), and Health Canada (Canada Vigilance). Availability and redistribution conditions differ by provider and dataset component; researchers should consult the providers' current terms and applicable institutional requirements.

This deposit excludes source-report records, report-level RDS objects, deduplicated case-level data, the quarterly grouped-input CSVs (`175G_*`), and dictionaries or terminology assets whose redistribution has not been cleared. Some quarterly grouped input cells contain low event counts; omission is precautionary pending privacy/disclosure and licensing review, not a claim that all such summaries are legally prohibited.

The aggregate `model_estimates.csv` and `model_replay_comparison.csv` do **not** include report identifiers, event-count cells, denominators, or quarter-level grouped rows. Their publication does not confer a license to reproduce or redistribute any source regulator records or restricted inputs.

The analysis scripts cannot recreate the reported estimates without the original grouped inputs. The full upstream transformations are not included in this code-only reproducibility subset.

**Source licensing assessment:** Official provider terms and precise regulator attribution for derived estimates are documented in `docs/source_data_attribution.md`; the creator’s license for the derived summary tables is described in `../RIGHTS.md`.
