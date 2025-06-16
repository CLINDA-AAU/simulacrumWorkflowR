library(testthat)

tumour_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_tumour.csv", package = "simulacrumWorkflowR")
random_tumour_data <- read.csv(tumour_data_dir, stringsAsFactors = FALSE) 

patient_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_patient.csv", package = "simulacrumWorkflowR")
random_patient_data <- read.csv(patient_data_dir, stringsAsFactors = FALSE) 


test_that("create_dir creates a new directory and shows message by default", {
  test_dir <- fs::path(tempdir(), "test_create_dir_new")
  
  if (fs::dir_exists(test_dir)) {
    fs::dir_delete(test_dir)
  }
  
  expect_message(
    create_dir(test_dir),
    paste0("Created path ", test_dir)
  )
  expect_true(fs::dir_exists(test_dir))
  
  if (fs::dir_exists(test_dir)) {
    fs::dir_delete(test_dir)
  }
})



av_patient_tumour_merge(random_patient_data, random_tumour_data)

expected_output <- data.frame(
  PATIENTID = 1:10,
  VITALSTATUSDATE = c("2022-12-12", "2022-12-12", "2022-12-12", "2022-12-12", "2022-12-12", "2022-12-12", 
                      "2022-12-12", "2022-12-12", "2022-12-12", "2022-12-12"),
  DEATHCAUSECODE_1A = "c50",
  VITALSTATUS = c("A", "D", "A", "A", "A", "A", "A", "A", "A", "A"),
  ETHNICITY = "D",
  DIAGNOSISDATEBEST = c("2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12",
                        "2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12"),
  SITE_ICD10_O2 = c("C50", "C53", "C54", "C55", "C56", "C50", "C53", "C54", "C55", "C56"),
  AGE = c(60, 43, 66, 61, 58, 62, 89, 54, 83, 34),
  SITE_ICD10_O2_3CHAR = c("C50", "C53", "C54", "C55", "C56", "C50", "C53", "C54", "C55", "C56"),
  PERFORMANCESTATUS = c(0, 3, 3, 1, 0, 2, 1, 2, 1, 0),
  GENDER = as.integer(c(2, 1, 1, 2, 2, 1, 2, 2, 1, 2)),
  TUMOURID = 1:10,
  ER_STATUS = 1:10,
  LATERALITY = rep(9, 10), 
  stringsAsFactors = FALSE 
)

test_that("av_patient_tumour_merge correctly merges patient and tumour data", {
  
  actual_output <- av_patient_tumour_merge(random_patient_data, random_tumour_data)
  

  expect_equal(actual_output, expected_output)
})
