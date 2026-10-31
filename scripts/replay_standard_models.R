# =============================================================================
# TADS_Standard_Grouped_Model_Replay_v0_1.R
# NEW INDEPENDENT REPLAY SCRIPT (2026-10-31). NOT AN ORIGINAL 2026-08-06 SCRIPT.
# The grouped input tables are withheld pending disclosure and licensing review.
#
# Scope: reproduce the 42 Stage6M STANDARD grouped-binomial models from three
# locally held, previously frozen 175G grouped-input CSVs, and compare against
# the frozen 175H estimate table. This does NOT reproduce the 13 bias-reduced
# sensitivity estimates or 12 no-estimate records, nor any upstream ETL.
#
# Data safety: read-only grouped CSV inputs; no RDS reads, no raw data access,
# no changes to Stage6M files, no raw/grouped rows copied to output, no URLs.
# Output: new private folder with numeric comparisons and disclosure counts.
# Requirements: R base + stats + tools only; no package installation.
# =============================================================================

options(stringsAsFactors = FALSE, warn = 1)

# Optional path to directory containing all four Stage6M CSVs; otherwise
# use a file-picker to select 175H_stage6M_database_specific_estimates.csv.
INPUT_DIR_OVERRIDE <- ""

# Optional output parent; defaults to the Desktop if it exists, otherwise home.
OUTPUT_PARENT_OVERRIDE <- ""

reference_file <- "175H_stage6M_database_specific_estimates.csv"
group_files <- c(
  "FAERS/AERS" = "175G_FAERS_AERS_grouped_model_inputs.csv",
  "JADER" = "175G_JADER_grouped_model_inputs.csv",
  "Canada Vigilance" = "175G_Canada_Vigilance_grouped_model_inputs.csv"
)

# Frozen Stage6M 175M Manifest references (confirmed in the preserved archive).
reference_md5 <- c(
  "175H_stage6M_database_specific_estimates.csv" = "a8086bf405dd57745a2d769f560f9d2f",
  "175G_FAERS_AERS_grouped_model_inputs.csv" = "80bef3a2739e2276afa4bc8a55849569",
  "175G_JADER_grouped_model_inputs.csv" = "9d0dcd085deae5f1a732c4822708e392",
  "175G_Canada_Vigilance_grouped_model_inputs.csv" = "2ca56677fa35f7a1b426ca86183117e5"
)
reference_bytes <- c(
  "175H_stage6M_database_specific_estimates.csv" = 24806,
  "175G_FAERS_AERS_grouped_model_inputs.csv" = 272223,
  "175G_JADER_grouped_model_inputs.csv" = 249357,
  "175G_Canada_Vigilance_grouped_model_inputs.csv" = 630861
)

assert <- function(ok, message) {
  if (!isTRUE(ok)) stop(message, call. = FALSE)
}

if (nzchar(INPUT_DIR_OVERRIDE)) {
  input_dir <- normalizePath(INPUT_DIR_OVERRIDE, winslash = "/", mustWork = TRUE)
} else {
  cat("Select the frozen 175H_stage6M_database_specific_estimates.csv file.\n")
  selected_file <- file.choose()
  assert(identical(basename(selected_file), reference_file),
         paste0("Selected file must be: ", reference_file))
  input_dir <- dirname(normalizePath(selected_file, winslash = "/", mustWork = TRUE))
}

input_paths <- file.path(input_dir, names(reference_md5))
assert(all(file.exists(input_paths)),
       paste0("Frozen CSV(s) missing from the SAME directory: ",
              paste(names(reference_md5)[!file.exists(input_paths)], collapse = ", "),
              ". If files were moved, set INPUT_DIR_OVERRIDE at script top."))

file_bytes <- as.numeric(file.info(input_paths)$size)
file_hashes <- unname(as.character(tools::md5sum(input_paths)))
input_qc <- data.frame(
  file_basename = names(reference_md5),
  expected_bytes = as.numeric(reference_bytes[names(reference_md5)]),
  observed_bytes = file_bytes,
  expected_md5 = unname(reference_md5),
  observed_md5 = file_hashes,
  bytes_match = file_bytes == as.numeric(reference_bytes[names(reference_md5)]),
  md5_match = !is.na(file_hashes) & tolower(file_hashes) == tolower(unname(reference_md5)),
  stringsAsFactors = FALSE
)
assert(all(input_qc$bytes_match & input_qc$md5_match),
       "Input file bytes/MD5 differ from the frozen Stage6M 175M Manifest. No model fitted.")

read_frozen_csv <- function(path) {
  tryCatch(
    read.csv(path, fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE,
             check.names = FALSE),
    error = function(e) {
      stop(paste0("Cannot read frozen CSV: ", basename(path), " :: ",
                  conditionMessage(e)), call. = FALSE)
    }
  )
}

ref <- read_frozen_csv(file.path(input_dir, reference_file))
assert(all(c("database", "analysis_id", "model_family", "method", "ROR",
             "coefficient", "standard_error", "periods_retained") %in% names(ref)),
       "175H reference table lacks required columns.")
assert(nrow(ref) == 67L,
       paste0("Unexpected 175H row count: ", nrow(ref), "; expected 67."))

standard_method <- "standard_grouped_binomial_glm"
bias_method <- "bias_reduced_grouped_binomial_glm"
methods <- table(factor(ref$method, levels = c(standard_method, bias_method, "none")))
assert(identical(as.integer(methods), c(42L, 13L, 12L)),
       "Unexpected historical model-method counts; expected 42 standard, 13 bias-reduced, 12 none.")
standard <- ref[ref$method == standard_method, , drop = FALSE]
assert(!anyDuplicated(paste(standard$database, standard$analysis_id, sep = "::")),
       "Duplicate database-analysis_id pairs in standard model reference.")

all_grouped <- list()
for (database_now in names(group_files)) {
  source_file <- group_files[[database_now]]
  x <- read_frozen_csv(file.path(input_dir, source_file))
  required_cols <- c("report_period", "exposure", "modifier", "events", "total",
                     "non_events", "database", "analysis_id", "retained_for_model")
  assert(all(required_cols %in% names(x)),
         paste0("Grouped file missing columns: ", source_file, " :: ",
                paste(setdiff(required_cols, names(x)), collapse = ", ")))
  assert(all(as.character(x$database) == database_now),
         paste0("Database labels do not match frozen filename: ", source_file))
  numeric_cols <- c("events", "total", "non_events")
  for (col in numeric_cols) {
    x[[col]] <- suppressWarnings(as.numeric(x[[col]]))
    assert(!anyNA(x[[col]]) && all(is.finite(x[[col]])),
           paste0("Invalid numeric count in ", source_file, ": ", col))
    assert(all(x[[col]] >= 0 & x[[col]] == floor(x[[col]])),
           paste0("Noninteger/negative count in ", source_file, ": ", col))
  }
  assert(all(x$events + x$non_events == x$total),
         paste0("Cell arithmetic failure in ", source_file))
  assert(all(x$total >= 1), paste0("Zero/negative grouped total: ", source_file))
  assert(!anyNA(x$report_period) &&
           all(grepl("^[0-9]{4}Q[1-4]$", as.character(x$report_period))),
         paste0("Invalid report-period labels: ", source_file))
  flags <- toupper(as.character(x$retained_for_model))
  assert(all(flags %in% c("TRUE", "FALSE", "T", "F", "1", "0")),
         paste0("Unexpected retained_for_model flag: ", source_file))
  x$retained_for_model <- flags %in% c("TRUE", "T", "1")
  all_grouped[[database_now]] <- x
}

# Release boundary: the 175G quarter-level tables contain cells in 1..4;
# counts below are metadata disclosure signals, never approval to publish 175G.
disclosure_rows <- lapply(names(all_grouped), function(db) {
  x <- all_grouped[[db]]
  retained <- x[x$retained_for_model, , drop = FALSE]
  data.frame(
    database = db,
    total_grouped_rows = nrow(x),
    model_retained_rows = nrow(retained),
    total_cells_1_to_4 = sum(x$total >= 1 & x$total <= 4),
    event_cells_1_to_4 = sum(x$events >= 1 & x$events <= 4),
    nonevent_cells_1_to_4 = sum(x$non_events >= 1 & x$non_events <= 4),
    retained_total_cells_1_to_4 = sum(retained$total >= 1 & retained$total <= 4),
    retained_event_cells_1_to_4 = sum(retained$events >= 1 & retained$events <= 4),
    release_decision = "HOLD_FOR_DISCLOSURE_AND_LICENSE_REVIEW",
    stringsAsFactors = FALSE
  )
})
disclosure_qc <- do.call(rbind, disclosure_rows)

fit_one <- function(db, analysis_id, family) {
  grouped <- all_grouped[[db]]
  x <- grouped[grouped$analysis_id == analysis_id & grouped$retained_for_model,
               , drop = FALSE]
  if (!nrow(x)) stop("No retained grouped rows.")
  assert(all(x$events + x$non_events == x$total), "Nonmatching grouped counts.")
  x$report_period <- factor(as.character(x$report_period))
  if (family %in% c("category", "component_category")) {
    assert(!anyNA(x$exposure) && all(x$exposure %in% c(0, 1)),
           "Invalid category exposure.")
    form <- cbind(events, non_events) ~ exposure + factor(report_period)
    target <- "exposure"
    group_vars <- c("report_period", "exposure")
  } else if (family == "within_glp1") {
    assert(!anyNA(x$modifier) && all(x$modifier %in% c(0, 1)),
           "Invalid within-GLP1 modifier.")
    form <- cbind(events, non_events) ~ modifier + factor(report_period)
    target <- "modifier"
    group_vars <- c("report_period", "modifier")
  } else if (family == "product") {
    assert(!anyNA(x$exposure) && all(x$exposure %in% c(0, 1)) &&
             !anyNA(x$modifier) && all(x$modifier %in% c(0, 1)),
           "Invalid product contrast.")
    form <- cbind(events, non_events) ~ exposure * modifier + factor(report_period)
    target <- "exposure:modifier"
    group_vars <- c("report_period", "exposure", "modifier")
  } else {
    stop(paste0("Unsupported model family: ", family))
  }
  assert(!anyDuplicated(x[, group_vars, drop = FALSE]),
         "Duplicate retained quarter/group cells.")
  warning_messages <- character()
  model <- withCallingHandlers(
    stats::glm(form, family = stats::binomial(), data = x),
    warning = function(w) {
      warning_messages <<- unique(c(warning_messages, conditionMessage(w)))
      invokeRestart("muffleWarning")
    }
  )
  co <- summary(model)$coefficients
  assert(target %in% rownames(co), "Target contrast not found in model coefficients.")
  beta <- unname(co[target, "Estimate"])
  se <- unname(co[target, "Std. Error"])
  assert(is.finite(beta) && is.finite(se), "Non-finite coefficient or SE.")
  list(
    coefficient = beta,
    se = se,
    ROR = exp(beta),
    lower_95 = exp(beta - 1.96 * se),
    upper_95 = exp(beta + 1.96 * se),
    periods_retained = length(unique(x$report_period)),
    fitted_rows = nrow(x),
    converged = isTRUE(model$converged),
    warnings = paste(warning_messages, collapse = " | ")
  )
}

replay_rows <- vector("list", nrow(standard))
for (i in seq_len(nrow(standard))) {
  ref_row <- standard[i, , drop = FALSE]
  db <- as.character(ref_row$database)
  aid <- as.character(ref_row$analysis_id)
  family <- as.character(ref_row$model_family)
  message("[", i, "/", nrow(standard), "] ", db, " :: ", aid)
  result <- tryCatch(fit_one(db, aid, family), error = function(e) e)
  failed <- inherits(result, "error")
  if (failed) {
    replay_rows[[i]] <- data.frame(
      database = db, analysis_id = aid, model_family = family,
      model_method = standard_method, status = "ERROR",
      ref_ROR = as.numeric(ref_row$ROR), replay_ROR = NA_real_,
      abs_ROR_diff = NA_real_, ref_SE = as.numeric(ref_row$standard_error),
      replay_SE = NA_real_, abs_SE_diff = NA_real_,
      ref_periods_retained = as.integer(ref_row$periods_retained),
      replay_periods_retained = NA_integer_,
      pass_ROR_1e_6 = FALSE, pass_SE_1e_4 = FALSE,
      pass_retained_periods = FALSE, converged = FALSE,
      warning_or_error = substr(conditionMessage(result), 1L, 400L),
      stringsAsFactors = FALSE
    )
  } else {
    ror_diff <- abs(result$ROR - as.numeric(ref_row$ROR))
    se_diff <- abs(result$se - as.numeric(ref_row$standard_error))
    period_pass <- identical(as.integer(result$periods_retained),
                             as.integer(ref_row$periods_retained))
    replay_rows[[i]] <- data.frame(
      database = db, analysis_id = aid, model_family = family,
      model_method = standard_method, status = "ESTIMATED",
      ref_ROR = as.numeric(ref_row$ROR), replay_ROR = result$ROR,
      abs_ROR_diff = ror_diff, ref_SE = as.numeric(ref_row$standard_error),
      replay_SE = result$se, abs_SE_diff = se_diff,
      ref_periods_retained = as.integer(ref_row$periods_retained),
      replay_periods_retained = as.integer(result$periods_retained),
      pass_ROR_1e_6 = is.finite(ror_diff) && ror_diff < 1e-6,
      pass_SE_1e_4 = is.finite(se_diff) && se_diff < 1e-4,
      pass_retained_periods = period_pass,
      converged = result$converged,
      warning_or_error = substr(result$warnings, 1L, 400L),
      stringsAsFactors = FALSE
    )
  }
}
replay <- do.call(rbind, replay_rows)
complete_pass <- nrow(replay) == 42L &&
  all(replay$status == "ESTIMATED") &&
  all(replay$pass_ROR_1e_6 & replay$pass_SE_1e_4 &
        replay$pass_retained_periods & replay$converged)

# Create a NEW directory outside the historical data directory, regardless
# of whether the user moved the prior workspace to another drive/folder.
output_parent <- if (nzchar(OUTPUT_PARENT_OVERRIDE)) {
  OUTPUT_PARENT_OVERRIDE
} else {
  desktop <- file.path(path.expand("~"), "Desktop")
  if (dir.exists(desktop)) desktop else path.expand("~")
}
assert(dir.exists(output_parent), "Output parent directory does not exist.")
name_base <- paste0("TADS_Standard_Grouped_Replay_",
                    format(Sys.time(), "%Y%m%d_%H%M%S"))
out_dir <- file.path(output_parent, name_base)
index <- 1L
while (dir.exists(out_dir)) {
  out_dir <- file.path(output_parent, paste0(name_base, "_", index))
  index <- index + 1L
}
assert(dir.create(out_dir, recursive = FALSE, showWarnings = FALSE),
       "Could not create the private output directory.")

write.csv(input_qc, file.path(out_dir, "01_Frozen_Input_MD5_and_Size.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(disclosure_qc, file.path(out_dir, "02_Quarterly_Cell_Disclosure_Preflight.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(replay, file.path(out_dir, "03_Independent_42_Model_Replay.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
method_scope <- data.frame(
  method = c(standard_method, bias_method, "none"),
  historical_rows = c(42L, 13L, 12L),
  replayed_now = c(nrow(replay), 0L, 0L),
  scope = c("NEW independent standard-model replay",
            "NOT REPLAYED: bias-reduced sensitivity models",
            "NOT REPLAYED: prespecified unavailable/no-estimate rows"),
  stringsAsFactors = FALSE
)
write.csv(method_scope, file.path(out_dir, "04_Comparison_Scope.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

summary_text <- c(
  "TADS grouped-binomial model replay: NEW implementation, not an original historical script.",
  paste0("Run time: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "Source basis: Stage6M 175G grouped-input files and 175H frozen estimate table.",
  "Frozen input identity: 4/4 MD5 and size matches before any GLM fitting.",
  paste0("Historical 175H methods: standard=", methods[[1L]],
         ", bias-reduced=", methods[[2L]], ", none=", methods[[3L]]),
  paste0("Standard models replayed: ", nrow(replay)),
  paste0("Standard models matching ROR tolerance (<1e-6): ",
         sum(replay$pass_ROR_1e_6)),
  paste0("Standard models matching SE tolerance (<1e-4): ",
         sum(replay$pass_SE_1e_4)),
  paste0("Models with correct retained quarters: ",
         sum(replay$pass_retained_periods)),
  paste0("Converged: ", sum(replay$converged)),
  paste0("Overall complete standard-model replay PASS: ", complete_pass),
  "",
  "IMPORTANT LIMITATIONS:",
  "- The new code independently fits 42 standard grouped-binomial models only.",
  "- It does not claim to be the original Stage6N independently executed source.",
  "- It does not fit 13 historical bias-reduced estimates or 12 none rows.",
  "- It does not access report-level RDS/raw FAERS/JADER/Canada records.",
  "- It does not reproduce upstream drug/outcome mapping, denominators or PT ETL.",
  "- No 175G input rows are exported or bundled into this output directory.",
  "- The 175G quarter-level grouped cells include small counts: PUBLIC RELEASE HOLD.",
  "- Human privacy/licensing review is mandatory before sharing the inputs.",
  "- This model-stage replay is not a claim of end-to-end reproducibility.",
  "",
  paste0("Output directory: ", out_dir)
)
writeLines(summary_text, file.path(out_dir, "05_Run_Summary.txt"), useBytes = TRUE)
cat(paste(summary_text, collapse = "\n"), "\n")
if (!complete_pass) {
  warning("At least one independent standard-model replay comparison failed. Review 03_Independent_42_Model_Replay.csv.",
          call. = FALSE)
}
