library(testthat)


test_that("test_read_simulacrum function works correctly", {
  package_name <- "simulacrumWorkflowR"
  data_dir <- system.file("extdata", "minisimulacrum", package = package_name)

  
    
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
  
  expect_no_error(result <- read_simulacrum(dir = data_dir))
  
  expect_type(result, "list") 
  
  expect_true(all(required_files_base %in% names(result)))
  
  expect_equal(length(result), length(required_files_base))
  
  for (file_name in required_files_base) {
    expect_s3_class(result[[file_name]], "data.frame")
  }
  
  expect_error(read_simulacrum(dir = "path/that/does/not/exist"), "Directory does not exist.")
  
  selected_files_test <- c("sim_av_gene", "sim_av_patient")
  result_selected <- read_simulacrum(dir = data_dir, selected_files = selected_files_test)
  expect_equal(names(result_selected), selected_files_test)
  expect_equal(length(result_selected), 2)
})
