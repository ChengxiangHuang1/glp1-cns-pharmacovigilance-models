# Check non-restricted published result-table arithmetic only.
# This does not rerun statistical models or access restricted grouped inputs.
# Run from repository root: Rscript scripts/verify_published_results.R
# Or: Rscript scripts/verify_published_results.R path/to/repository
args <- commandArgs(trailingOnly = TRUE)
repo <- if (length(args)) normalizePath(args[[1L]], winslash = "/", mustWork = TRUE) else getwd()
find_result <- function(nm) {
  p <- file.path(repo, "results", nm)
  if (!file.exists(p)) stop("Missing result file: ", p, call. = FALSE)
  p
}
stop_unless <- function(cond, msg) if (!isTRUE(cond)) stop(msg, call. = FALSE)
read_result <- function(nm) read.csv(find_result(nm), check.names = FALSE,
                                    stringsAsFactors = FALSE)
a <- read_result("model_estimates.csv")
b <- read_result("model_replay_comparison.csv")
keys <- c("database", "analysis_id", "method")
stop_unless(all(c(keys,"ROR","standard_error") %in% names(a)), "Estimates schema mismatch")
stop_unless(all(c(keys,"frozen_ROR","independent_ROR","ROR_absolute_difference",
                  "frozen_standard_error","independent_standard_error",
                  "SE_absolute_difference","converged","comparison_pass") %in% names(b)),
            "Comparison schema mismatch")
stop_unless(nrow(a) == 67L && nrow(b) == 55L, "Unexpected model row counts")
expected <- c(standard_grouped_binomial_glm = 42L,
              bias_reduced_grouped_binomial_glm = 13L, none = 12L)
actual <- table(factor(a$method, levels = names(expected)))
stop_unless(identical(as.integer(actual), as.integer(expected)), "Unexpected method groups")
key <- function(x) do.call(paste, c(x[keys], sep = "||"))
ka <- key(a);kb <- key(b)
stop_unless(!anyDuplicated(ka) && !anyDuplicated(kb), "Duplicate joint model keys")
i <- match(kb, ka)
stop_unless(!anyNA(i), "Replay models missing from frozen estimates")
stop_unless(all(b$comparison_pass %in% c(TRUE, 1)) && all(b$converged %in% c(TRUE,1)),
            "A replay comparison is not flagged as passed/converged")
stop_unless(all(is.finite(b$ROR_absolute_difference)) &&
              all(b$ROR_absolute_difference < 1e-6), "ROR difference threshold failed")
stop_unless(all(is.finite(b$SE_absolute_difference)) &&
              all(b$SE_absolute_difference < 1e-4), "SE difference threshold failed")
stop_unless(max(abs(as.numeric(b$frozen_ROR) - as.numeric(a$ROR[i]))) < 1e-9,
            "Frozen ROR columns disagree")
stop_unless(max(abs(as.numeric(b$frozen_standard_error) -
                    as.numeric(a$standard_error[i]))) < 1e-9,
            "Frozen standard errors disagree")
stop_unless(max(abs(abs(b$independent_ROR - b$frozen_ROR) -
                b$ROR_absolute_difference)) < 1e-9, "Reported ROR differences disagree")
stop_unless(max(abs(abs(b$independent_standard_error - b$frozen_standard_error) -
                b$SE_absolute_difference)) < 1e-9, "Reported SE differences disagree")
cat("Aggregate result-table integrity: PASS\n")
cat("Frozen model rows: 67; replayed estimate rows: 55 (42 standard, 13 bias-reduced).\n")
cat("The input-level model reproduction requires withheld 175G grouped tables.\n")
