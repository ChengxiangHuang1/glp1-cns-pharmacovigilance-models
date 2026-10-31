# Inputs for numerical model replay

Four CSVs must reside in one directory. Both replay scripts verify exact size and MD5 of the archived inputs; inputs with different bytes stop before estimation.

| CSV | Size (bytes) | MD5 |
| --- | ---: | --- |
| `175H_stage6M_database_specific_estimates.csv` | 24806 | `a8086bf405dd57745a2d769f560f9d2f` |
| `175G_FAERS_AERS_grouped_model_inputs.csv` | 272223 | `80bef3a2739e2276afa4bc8a55849569` |
| `175G_JADER_grouped_model_inputs.csv` | 249357 | `9d0dcd085deae5f1a732c4822708e392` |
| `175G_Canada_Vigilance_grouped_model_inputs.csv` | 630861 | `2ca56677fa35f7a1b426ca86183117e5` |

### Reference file (175H)

Required fields: `database`, `analysis_id`, `model_family`, `method`, `ROR`, `standard_error`, `coefficient`, `periods_retained`; bias-reduced replay additionally verifies `model_rank`, `n_coefficients`, and `model_status`.

### Grouped-input files (175G)

Required fields include `database`, `analysis_id`, `report_period`, `exposure`, `modifier`, `events`, `non_events`, `total`, and `retained_for_model`. Some analysis families legitimately omit `exposure` or `modifier`. Bias-reduced product models require both variables. Source row counts and individual quarter-level observations are **not distributed**.

The replay routines verify numerical estimates against frozen values under fixed source-file identity; they are not general estimators with automatic support for arbitrary regulatory releases. See `data_access.md` for source-data restrictions.
