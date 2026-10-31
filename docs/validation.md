# Model replay validation

Numerical checks were carried out using independent replay scripts run in R 4.6.0 on Windows 11 and verified against preserved Stage6M estimate records.

| Method | Replayed estimates | Within tolerance | Converged |
| --- | ---: | ---: | ---: |
| Standard grouped-binomial logistic regression | 42 | 42 | 42 |
| Mean-bias-reduced grouped-binomial logistic regression | 13 | 13 | 13 |
| Not estimated in the historical analysis | 12 | Not refitted | Not applicable |

Matching criteria: absolute ROR difference < 1 × 10⁻⁶; absolute coefficient standard-error difference < 1 × 10⁻⁴. Retained report-quarter counts agree. For the bias-reduced fits, the model rank and number of coefficients also agree. These criteria were checked for every eligible record.

**Observed maximum absolute differences:** standard ROR 2.8422e-14, standard SE 4.7184e-16; bias-reduced ROR 4.4409e-15, bias-reduced SE 3.8858e-16.

The 55 replays were executed on the researcher's Windows R environment. Uploaded reports were crosschecked against the frozen reference table and expected input hashes. These files do not establish end-to-end regeneration from regulatory source downloads. The 12 original no-estimate results remain unchanged.
