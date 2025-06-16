library(testthat)

tumour_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_tumour.csv", package = "simulacrumWorkflowR")
random_tumour_data <- read.csv(tumour_data_dir, stringsAsFactors = FALSE) 

patient_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_patient.csv", package = "simulacrumWorkflowR")
random_patient_data <- read.csv(patient_data_dir, stringsAsFactors = FALSE) 




expected_output_data <- data.frame(
  PATIENTID = 1:10,
  DIAGNOSISDATEBEST = c("2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12",
                       "2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12", "2014-12-12"),
  SITE_ICD10_O2 = c("C50", "C53", "C54", "C55", "C56", "C50", "C53", "C54", "C55", "C56"),
  AGE = c(60, 43, 66, 61, 58, 62, 89, 54, 83, 34),
  SITE_ICD10_O2_3CHAR = c("C50", "C53", "C54", "C55", "C56", "C50", "C53", "C54", "C55", "C56"),
  PERFORMANCESTATUS = c(0, 3, 3, 1, 0, 2, 1, 2, 1, 0),
  GENDER = c(2, 1, 1, 2, 2, 1, 2, 2, 1, 2),
  TUMOURID = 1:10,
  ER_STATUS = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
  LATERALITY = rep(9, 10), 
  diag_group = c(
    "Breast",
    "Gynaecological",
    "Gynaecological",
    "Gynaecological",
    "Gynaecological",
    "Breast",
    "Gynaecological",
    "Gynaecological",
    "Gynaecological",
    "Gynaecological"
  ),
  stringsAsFactors = FALSE
)

test_that("cancer_grouping function correctly assigns diagnosis groups for random_tumour_data", {
  
  actual_output_data <- cancer_grouping(random_tumour_data)
  
  expect_equal(actual_output_data, expected_output_data)
  
  expect_error(cancer_grouping("not a data frame"), "`df` must be a data frame.")
  
})



expected_output_ethnicity_test <- structure(list( 
  PATIENTID = 1:10,
  VITALSTATUSDATE = c("2022-12-12", "2022-12-12", "2022-12-12",
                      "2022-12-12", "2022-12-12", "2022-12-12",
                      "2022-12-12", "2022-12-12", "2022-12-12",
                      "2022-12-12"),
  DEATHCAUSECODE_1A = c("c50", "c50", "c50", "c50", "c50", "c50",
                        "c50", "c50", "c50", "c50"),
  VITALSTATUS = c("A", "A", "A", "A", "A", "A", "A", "A", "A", "A"),
  ETHNICITY = c("D", "D", "D", "D", "D", "D", "D", "D", "D", "D"),
  Grouped_Ethnicity = c("Mixed", "Mixed", "Mixed", "Mixed", "Mixed",
                        "Mixed", "Mixed", "Mixed", "Mixed", "Mixed")
), class = "data.frame", row.names = c(NA, -10))


test_that("group_ethnicity correctly maps ETHNICITY code 'D' to 'Mixed'", {
  test_patient_data_for_ethnicity_test <- structure(list(
    PATIENTID = 1:10,
    VITALSTATUSDATE = c("2022-12-12", "2022-12-12", "2022-12-12",
                        "2022-12-12", "2022-12-12", "2022-12-12",
                        "2022-12-12", "2022-12-12", "2022-12-12",
                        "2022-12-12"),
    DEATHCAUSECODE_1A = c("c50", "c50", "c50", "c50", "c50", "c50",
                          "c50", "c50", "c50", "c50"),
    VITALSTATUS = c("A", "A", "A", "A", "A", "A", "A", "A", "A", "A"),
    ETHNICITY = c("D", "D", "D", "D", "D", "D", "D", "D", "D", "D")
  ), class = "data.frame", row.names = c(NA, -10))
  
  
  actual_output <- group_ethnicity(test_patient_data_for_ethnicity_test)
  
  expect_equal(actual_output, expected_output_ethnicity_test) 
  
  expect_error(group_ethnicity("not a data frame"), "`df` must be a data frame.")
  
})

df_merged <- av_patient_tumour_merge(random_patient_data, random_tumour_data)
df_merged


survival_days(df_merged)

test_that("survival_days calculates date differences and status correctly", {
  
  df_merged_input <- data.frame(
    PATIENTID = 1:10,
    VITALSTATUSDATE = as.Date(rep("2022-12-12", 10)),
    DEATHCAUSECODE_1A = rep("c50", 10),
    VITALSTATUS = rep("A", 10),
    ETHNICITY = rep("D", 10),
    DIAGNOSISDATEBEST = as.Date(rep("2014-12-12", 10)),
    SITE_ICD10_O2 = c("C50", "C53", "C54", "C55", "C56", "C50", "C53", "C54", "C55", "C56"),
    AGE = c(60, 43, 66, 61, 58, 62, 89, 54, 83, 34),
    SITE_ICD10_O2_3CHAR = c("C50", "C53", "C54", "C55", "C56", "C50", "C53", "C54", "C55", "C56"),
    PERFORMANCESTATUS = c(0, 3, 3, 1, 0, 2, 1, 2, 1, 0),
    GENDER = c(2, 1, 1, 2, 2, 1, 2, 2, 1, 2),
    TUMOURID = 1:10,
    ER_STATUS = 1:10,
    LATERALITY = rep(9, 10)
  )
  
  df_expected_output <- df_merged_input
  df_expected_output$diff_date <- 2922
  df_expected_output$time_to_death <- as.numeric(NA)
  df_expected_output$status_OS <- 0
  df_expected_output$Time_OS <- 2922
  
  df_actual_output <- survival_days(df_merged_input)
  
  expect_equal(df_actual_output, df_expected_output)
})
