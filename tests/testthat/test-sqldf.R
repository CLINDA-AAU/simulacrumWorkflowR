library(testthat)
library(sqldf)

test_that("query_sql correctly joins patient and tumour data and limits results", {
  
  tumour_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_tumour.csv", package = "simulacrumWorkflowR")
  random_tumour_data <- read.csv(tumour_data_dir, stringsAsFactors = FALSE) 
  
  patient_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_patient.csv", package = "simulacrumWorkflowR")
  random_patient_data <- read.csv(patient_data_dir, stringsAsFactors = FALSE) 
  
  
  if (!file.exists(patient_data_dir)) {
    stop("Patient data file not found at: ", patient_data_dir)
  }
  if (!file.exists(tumour_data_dir)) {
    stop("Tumour data file not found at: ", tumour_data_dir)
  }
  
  
  SIM_AV_PATIENT <- random_patient_data
  SIM_AV_TUMOUR <- random_tumour_data
  
  query_sql <- function(query) {
    if(!is.character(query))
      stop("The function must contain a string")
    sqldf(query, stringsAsFactors = FALSE)
  }
  
  query <- "SELECT age, performancestatus
            FROM SIM_AV_PATIENT
            INNER JOIN SIM_AV_TUMOUR ON SIM_AV_PATIENT.patientid = SIM_AV_TUMOUR.patientid
            limit 3;"
  
  expected_df <- data.frame(
    AGE = c(60, 43, 66),
    PERFORMANCESTATUS = c(0, 3, 3),
    stringsAsFactors = FALSE
  )
  
  actual_df <- query_sql(query)
  
  expect_equal(actual_df, expected_df)
  
})

test_that("query_sql provides error for non-character input", {
  
  query_sql <- function(query) {
    if(!is.character(query))
      stop("The function must contain a string")
    sqldf(query, stringsAsFactors = FALSE)
  }
  
  expect_error(query_sql(123), "The function must contain a string")
})
