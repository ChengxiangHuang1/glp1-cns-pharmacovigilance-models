# =============================================================================
# TADS_Bias_Reduced_Model_Replay_v0_2.R
# Independent model replay; not the original data-processing / historical Stage6N scripts.
# The 175G grouped inputs require authorization and are not distributed with this archive.
# Fits the 13 bias-reduced, grouped-binomial product-interaction models only.
# v0.2 repair: exposure/modifier are structurally blank in other model families;
# validate them only for the 13 target product interactions, without imputing.
# Verifies 175G/175H frozen byte identities before any fitting.
# Original research files are never modified; no RDS/raw case-level data read.
# =============================================================================
options(stringsAsFactors = FALSE, warn = 1)

# Optional: point directly to the directory containing all four frozen CSVs.
# Leave empty to choose the 175H file using a file picker.
INPUT_DIR_OVERRIDE <- ""
OUTPUT_PARENT_OVERRIDE <- ""

reference_name <- "175H_stage6M_database_specific_estimates.csv"
group_names <- c(
  "FAERS/AERS" = "175G_FAERS_AERS_grouped_model_inputs.csv",
  "JADER" = "175G_JADER_grouped_model_inputs.csv",
  "Canada Vigilance" = "175G_Canada_Vigilance_grouped_model_inputs.csv"
)
frozen_md5 <- c(
  "175H_stage6M_database_specific_estimates.csv" = "a8086bf405dd57745a2d769f560f9d2f",
  "175G_FAERS_AERS_grouped_model_inputs.csv" = "80bef3a2739e2276afa4bc8a55849569",
  "175G_JADER_grouped_model_inputs.csv" = "9d0dcd085deae5f1a732c4822708e392",
  "175G_Canada_Vigilance_grouped_model_inputs.csv" = "2ca56677fa35f7a1b426ca86183117e5"
)
frozen_bytes <- c(
  "175H_stage6M_database_specific_estimates.csv" = 24806,
  "175G_FAERS_AERS_grouped_model_inputs.csv" = 272223,
  "175G_JADER_grouped_model_inputs.csv" = 249357,
  "175G_Canada_Vigilance_grouped_model_inputs.csv" = 630861
)
assert <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
}

if (nzchar(INPUT_DIR_OVERRIDE)) {
  input_dir <- normalizePath(INPUT_DIR_OVERRIDE, winslash = "/", mustWork = TRUE)
} else {
  cat("Select 175H_stage6M_database_specific_estimates.csv (one of four frozen inputs).\n")
  selected_file <- file.choose()
  assert(identical(basename(selected_file), reference_name),
         "The selected file must be 175H_stage6M_database_specific_estimates.csv")
  input_dir <- dirname(normalizePath(selected_file, winslash = "/", mustWork = TRUE))
}

paths <- file.path(input_dir, names(frozen_md5))
assert(all(file.exists(paths)),
       paste("Frozen input files missing:",
             paste(names(frozen_md5)[!file.exists(paths)], collapse = "; ")))
actual_bytes <- as.numeric(file.info(paths)$size)
actual_md5 <- unname(as.character(tools::md5sum(paths)))
input_qc <- data.frame(
  filename = names(frozen_md5), expected_bytes = as.numeric(frozen_bytes[names(frozen_md5)]),
  observed_bytes = actual_bytes, expected_md5 = unname(frozen_md5),
  observed_md5 = actual_md5,
  bytes_match = actual_bytes == as.numeric(frozen_bytes[names(frozen_md5)]),
  md5_match = !is.na(actual_md5) & tolower(actual_md5) == tolower(unname(frozen_md5)),
  stringsAsFactors = FALSE
)
assert(all(input_qc$bytes_match & input_qc$md5_match),
       "One or more frozen inputs do not match the Stage6M manifest; fitting stopped.")
assert(requireNamespace("brglm2", quietly = TRUE),
       "Missing brglm2. Do not install/change packages within this script.")
package_version_now <- as.character(utils::packageVersion("brglm2"))
assert(identical(package_version_now, "1.1.0"),
       paste("brglm2 version mismatch:", package_version_now, "; expected 1.1.0"))

read_one <- function(path) {
  read.csv(path, fileEncoding = "UTF-8-BOM", check.names = FALSE,
           stringsAsFactors = FALSE)
}
ref <- read_one(file.path(input_dir, reference_name))
needed <- c("database", "analysis_id", "model_family", "method", "ROR",
            "standard_error", "coefficient", "periods_retained",
            "model_rank", "n_coefficients", "model_status")
assert(all(needed %in% names(ref)), "175H is missing required reference columns")
assert(nrow(ref) == 67L, "Expected exactly 67 Stage6M result records")
method_counts <- table(factor(
  ref$method,
  levels = c("standard_grouped_binomial_glm", "bias_reduced_grouped_binomial_glm", "none")
))
assert(identical(as.integer(method_counts), c(42L, 13L, 12L)),
       "Expected 42 standard, 13 bias-reduced, 12 no-estimate reference records")
bias <- ref[ref$method == "bias_reduced_grouped_binomial_glm", , drop = FALSE]
assert(nrow(bias) == 13L && all(bias$model_family == "product"),
       "Expected precisely 13 product-family bias-reduced estimates")
assert(!anyDuplicated(paste(bias$database, bias$analysis_id, bias$method, sep = "||")),
       "Duplicate bias-reduced reference model key")

all_grouped <- list()
for (db in names(group_names)) {
  x <- read_one(file.path(input_dir, group_names[[db]]))
  required <- c("database", "analysis_id", "report_period", "exposure", "modifier",
                "events", "non_events", "total", "retained_for_model")
  assert(all(required %in% names(x)), "175G is missing required grouped columns")
  assert(all(as.character(x$database) == db), "175G database labels inconsistent")
  # Counts are defined for every 175G model family and must be complete.
  # Exposure and modifier are structurally absent for some OTHER model
  # families (for example, within-GLP1 or category models). Those blanks
  # MUST NOT be imputed to zero; validation is restricted to relevant models.
  for (col in c("events", "non_events", "total")) {
    x[[col]] <- suppressWarnings(as.numeric(x[[col]]))
    assert(!anyNA(x[[col]]) && all(is.finite(x[[col]])),
           paste("Invalid grouped count:", db, col))
  }
  x$exposure <- suppressWarnings(as.numeric(x$exposure))
  x$modifier <- suppressWarnings(as.numeric(x$modifier))
  assert(all(x$events >= 0 & x$non_events >= 0 & x$total >= 1 &
               x$events == floor(x$events) &
               x$non_events == floor(x$non_events) &
               x$total == floor(x$total)), "Invalid grouped integer counts")
  assert(all(x$events + x$non_events == x$total), "Grouped arithmetic mismatch")
  # Only the 13 bias-reduced PRODUCT models are fitted in this script.
  # In those models, BOTH exposure and modifier must be present and 0/1.
  selected_ids <- as.character(bias$analysis_id[bias$database == db])
  selected_rows <- x$analysis_id %in% selected_ids
  assert(length(selected_ids) > 0L && any(selected_rows),
         paste("Missing bias-reduced product input rows:", db))
  assert(!anyNA(x$exposure[selected_rows]) &&
           all(x$exposure[selected_rows] %in% 0:1) &&
           !anyNA(x$modifier[selected_rows]) &&
           all(x$modifier[selected_rows] %in% 0:1),
         paste("Invalid product-model exposure/modifier:", db))
  assert(!anyNA(x$report_period) &&
           all(grepl("^[0-9]{4}Q[1-4]$", x$report_period)),
         "Unrecognized quarter label")
  flags <- toupper(as.character(x$retained_for_model))
  assert(all(flags %in% c("TRUE", "FALSE", "T", "F", "1", "0")),
         "Unrecognized retained_for_model flag")
  x$retained_for_model <- flags %in% c("TRUE", "T", "1")
  all_grouped[[db]] <- x
}

replay_one <- function(db, analysis_id) {
  x <- all_grouped[[db]]
  x <- x[x$analysis_id == analysis_id & x$retained_for_model, , drop = FALSE]
  assert(nrow(x) > 0L, "No retained grouped rows")
  assert(!anyDuplicated(x[, c("report_period", "exposure", "modifier"), drop = FALSE]),
         "Duplicate quarter/exposure/modifier cells")
  x$report_period <- factor(as.character(x$report_period))
  warn_text <- character()
  fit <- withCallingHandlers(
    stats::glm(cbind(events, non_events) ~ exposure * modifier + factor(report_period),
               family = stats::binomial(), data = x,
               method = brglm2::brglmFit, type = "AS_mean"),
    warning = function(w) {
      warn_text <<- unique(c(warn_text, conditionMessage(w)))
      invokeRestart("muffleWarning")
    }
  )
  coefficients_now <- summary(fit)$coefficients
  target <- "exposure:modifier"
  assert(target %in% rownames(coefficients_now), "Interaction target term unavailable")
  beta <- as.numeric(coefficients_now[target, "Estimate"])
  se <- as.numeric(coefficients_now[target, "Std. Error"])
  assert(is.finite(beta) && is.finite(se) && se >= 0, "Nonfinite target estimate")
  list(ROR = exp(beta), SE = se, coefficient = beta,
       retained_quarters = length(levels(x$report_period)),
       converged = isTRUE(fit$converged),
       model_rank = as.integer(fit$rank), n_coefficients = length(stats::coef(fit)),
       warnings = paste(warn_text, collapse = " | "))
}

rows <- vector("list", nrow(bias))
for (i in seq_len(nrow(bias))) {
  rr <- bias[i, , drop = FALSE]
  db <- as.character(rr$database)
  aid <- as.character(rr$analysis_id)
  message("[", i, "/", nrow(bias), "] ", db, " :: ", aid)
  result <- tryCatch(replay_one(db, aid), error = function(e) e)
  failed <- inherits(result, "error")
  if (failed) {
    rows[[i]] <- data.frame(
      database = db, analysis_id = aid, model_method = as.character(rr$method),
      status = "ERROR", ref_ROR = as.numeric(rr$ROR), replay_ROR = NA_real_,
      abs_ROR_diff = NA_real_, ref_SE = as.numeric(rr$standard_error),
      replay_SE = NA_real_, abs_SE_diff = NA_real_,
      ref_coefficient = as.numeric(rr$coefficient), replay_coefficient = NA_real_,
      ref_periods = as.integer(rr$periods_retained), replay_periods = NA_integer_,
      ref_model_rank = as.integer(rr$model_rank), replay_model_rank = NA_integer_,
      ref_n_coefficients = as.integer(rr$n_coefficients), replay_n_coefficients = NA_integer_,
      pass_ROR = FALSE, pass_SE = FALSE, pass_periods = FALSE,
      pass_rank = FALSE, pass_n_coefficients = FALSE, converged = FALSE,
      warning_or_error = substr(conditionMessage(result), 1L, 450L),
      stringsAsFactors = FALSE
    )
  } else {
    ror_diff <- abs(result$ROR - as.numeric(rr$ROR))
    se_diff <- abs(result$SE - as.numeric(rr$standard_error))
    rows[[i]] <- data.frame(
      database = db, analysis_id = aid, model_method = as.character(rr$method),
      status = "ESTIMATED", ref_ROR = as.numeric(rr$ROR),
      replay_ROR = result$ROR, abs_ROR_diff = ror_diff,
      ref_SE = as.numeric(rr$standard_error), replay_SE = result$SE,
      abs_SE_diff = se_diff, ref_coefficient = as.numeric(rr$coefficient),
      replay_coefficient = result$coefficient,
      ref_periods = as.integer(rr$periods_retained),
      replay_periods = as.integer(result$retained_quarters),
      ref_model_rank = as.integer(rr$model_rank), replay_model_rank = as.integer(result$model_rank),
      ref_n_coefficients = as.integer(rr$n_coefficients),
      replay_n_coefficients = as.integer(result$n_coefficients),
      pass_ROR = is.finite(ror_diff) && ror_diff < 1e-6,
      pass_SE = is.finite(se_diff) && se_diff < 1e-4,
      pass_periods = identical(as.integer(rr$periods_retained),
                               as.integer(result$retained_quarters)),
      pass_rank = identical(as.integer(rr$model_rank), as.integer(result$model_rank)),
      pass_n_coefficients = identical(as.integer(rr$n_coefficients),
                                     as.integer(result$n_coefficients)),
      converged = isTRUE(result$converged),
      warning_or_error = substr(result$warnings, 1L, 450L),
      stringsAsFactors = FALSE
    )
  }
}
replay <- do.call(rbind, rows)
complete_pass <- nrow(replay) == 13L &&
  all(replay$status == "ESTIMATED") &&
  all(replay$pass_ROR & replay$pass_SE & replay$pass_periods &
        replay$pass_rank & replay$pass_n_coefficients & replay$converged)

output_parent <- if (nzchar(OUTPUT_PARENT_OVERRIDE)) {
  OUTPUT_PARENT_OVERRIDE
} else {
  desktop <- file.path(path.expand("~"), "Desktop")
  if (dir.exists(desktop)) desktop else path.expand("~")
}
assert(dir.exists(output_parent), "Output parent directory does not exist")
base <- paste0("TADS_Bias_Reduced_Replay_", format(Sys.time(), "%Y%m%d_%H%M%S"))
out <- file.path(output_parent, base)
idx <- 1L
while (dir.exists(out)) {
  out <- file.path(output_parent, paste0(base, "_", idx))
  idx <- idx + 1L
}
assert(dir.create(out, recursive = FALSE, showWarnings = FALSE),
       "Could not create a private output directory")
write.csv(input_qc, file.path(out, "01_Frozen_Input_Identity.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(replay, file.path(out, "02_Independent_13_Bias_Reduced_Model_Replay.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
none <- ref[ref$method == "none",
            c("database", "analysis_id", "method", "model_status"), drop = FALSE]
none$disposition <- "HISTORICAL_NO_ESTIMATE__NOT_FITTED"
write.csv(none, file.path(out, "03_Historical_No_Estimate_Scope.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
sum_lines <- c(
  "TADS NEW independent bias-reduced replay v0.2; not the original Stage6M/Stage6N code.",
  paste("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  paste("R version:", getRversion()),
  paste("brglm2 version:", package_version_now),
  "Frozen inputs: 4/4 MD5 and byte length match BEFORE fitting.",
  "Historical Stage6M: 42 standard models, 13 bias-reduced models, 12 no-estimate rows.",
  paste("Bias-reduced models fitted:", nrow(replay)),
  paste("ROR tolerance (<1e-6):", sum(replay$pass_ROR)),
  paste("SE tolerance (<1e-4):", sum(replay$pass_SE)),
  paste("Retained-quarter matches:", sum(replay$pass_periods)),
  paste("Rank matches:", sum(replay$pass_rank)),
  paste("Number-of-coefficient matches:", sum(replay$pass_n_coefficients)),
  paste("Converged:", sum(replay$converged)),
  paste("Complete 13-model replay PASS:", complete_pass),
  "", "BOUNDARIES:",
  "- The 13 bias-reduced fits use brglm2::brglmFit, type=AS_mean (product interaction).",
  "- This replay does NOT re-run the 42 standard models; they were validated separately.",
  "- The 12 historical no-estimate rows are inventoried but are not refitted.",
  "- Stage6M raw source and RDS are unchanged; 175G files are READ ONLY.",
  "- 175G quarterly grouped input tables contain low counts and are NOT cleared for public release.",
  "- No original grouped-input rows or report-level data are included in outputs.",
  "- Not evidence of reproduction from official raw source data.",
  "",paste("Output directory:", out)
)
writeLines(sum_lines, file.path(out, "04_Run_Summary.txt"), useBytes = TRUE)
cat(paste(sum_lines, collapse = "\n"), "\n")
if (!complete_pass) {
  warning("One or more of the 13 bias-reduced models failed a predeclared check; review CSV.",
          call. = FALSE)
}
