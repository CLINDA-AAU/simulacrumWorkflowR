library(testthat)
library(pbapply)
library(tools)
options(warn=-1)


test_read_simulacrum <- function(dir = NULL, package = NULL, selected_files = NULL) {
  required_files <- c(
    "sim_av_gene.csv",
    "sim_av_patient.csv",
    "sim_av_tumour.csv",
    "sim_rtds_combined.csv",
    "sim_rtds_episode.csv",
    "sim_rtds_exposure.csv",
    "sim_rtds_prescription.csv",
    "sim_sact_cycle.csv",
    "sim_sact_drug_detail.csv",
    "sim_sact_outcome.csv",
    "sim_sact_regimen.csv"
  )
  
  data_dir <- if (!is.null(dir)) {
    dir
  } else if (!is.null(package)) {
    system.file("extdata", "minisimulacrum", package = package)
  } else {
    "inst/extdata/minisimulacrum/"
  }

  if (!is.null(dir)) {
    if (!is.character(dir)) {
      stop("Please make sure the input dir is a string.")
    }
    if (!dir.exists(dir)) {
      stop("Directory does not exist. Please check the path.")
    }
  }
  if (!dir.exists(data_dir)) {
    stop(sprintf("Determined data directory does not exist: %s", data_dir))
  }

  all_csv_files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
  available_files <- basename(all_csv_files)
  
  missing_files <- setdiff(required_files, available_files)
  if (length(missing_files) > 0) {
    stop("Missing required files: ", paste(missing_files, collapse = ", "))
  }
  
  files_to_read <- if (is.null(selected_files)) {
    file.path(data_dir, required_files) # Construct full paths for required files
  } else {
    matched_files <- paste0(selected_files, ".csv")
    full_matched_files <- file.path(data_dir, matched_files)
    files <- all_csv_files[all_csv_files %in% full_matched_files]
    if (length(files) == 0) stop("No matching files found for selected files.")
    files
  }
  
  data_list <- pbapply::pblapply(files_to_read, function(file) {
    table_name <- tools::file_path_sans_ext(basename(file))
    message(sprintf("Reading: %s", table_name))
    read.csv(file, stringsAsFactors = FALSE)
  })
  
  names(data_list) <- tools::file_path_sans_ext(basename(files_to_read))
  message("Files successfully loaded!")
  warning("Please refer to tables by their original names, capitalized as presented (e.g., SIM_AV_PATIENT)")
  return(data_list)
  
}


test_that("test_read_simulacrum function works correctly", {
  package_name <- "simulacrumWorkflowR"
  data_dir_in_package <- system.file("extdata", "minisimulacrum", package = package_name)
  
  required_files_base <- c(
    "sim_av_gene",
    "sim_av_patient",
    "sim_av_tumour",
    "sim_rtds_combined",
    "sim_rtds_episode",
    "sim_rtds_exposure",
    "sim_rtds_prescription",
    "sim_sact_cycle",
    "sim_sact_drug_detail",
    "sim_sact_outcome",
    "sim_sact_regimen"
  )
  
  expect_no_error(result <- test_read_simulacrum(package = package_name))
  
  expect_is(result, "list")
  
  expect_true(all(required_files_base %in% names(result)))
  
  expect_equal(length(result), length(required_files_base))
  
  for (file_name in required_files_base) {
    expect_is(result[[file_name]], "data.frame")
  }
  
})
  
