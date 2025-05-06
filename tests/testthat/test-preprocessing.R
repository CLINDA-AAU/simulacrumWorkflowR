library(testthat)
library(simulacrumWorkflowR)
library(dplyr)


tumour_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_tumour.csv", package = "simulacrumWorkflowR")
random_tumour_data <- read.csv(tumour_data_dir, stringsAsFactors = FALSE) 

patient_data_dir <- system.file("extdata", "minisimulacrum", "sim_av_patient.csv", package = "simulacrumWorkflowR")
random_patient_data <- read.csv(patient_data_dir, stringsAsFactors = FALSE) 




cancer_grouping <- function(df) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.")
  }
  
  df <- dplyr::mutate(df,
                      ip = as.numeric(substr(SITE_ICD10_O2_3CHAR, 2, 3)),
                      diag_group = dplyr::case_when(
                        ip %in% c(47, 69:72) ~ "Eye, brain and CNS",
                        ip %in% c(50) ~ "Breast",
                        ip %in% c(51:58) ~ "Gynaecological",
                        ip %in% c(0:14, 30:32) ~ "Head and Neck",
                        ip %in% c(18:21) ~ "Lower gastrointestinal",
                        ip %in% c(33:34, 37:39, 45) ~ "Lung and bronchus",
                        ip %in% c(15:17, 22:25) ~ "Upper gastrointestinal",
                        ip %in% c(60:68) ~ "Urology",
                        ip %in% c(43:44) ~ "Skin",
                        ip %in% c(81:86, 90:96) ~ "Haematologic",
                        TRUE ~ "Ill-defined and unspecified"
                      ),
                      diag_group = ifelse(substr(SITE_ICD10_O2_3CHAR, 1, 1) == "C",
                                          diag_group,
                                          "Other")
  )
  df <- dplyr::select(df, -ip)
  
  return(df)
}

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



random_patient_data <- structure(list(
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

group_ethnicity <- function(df) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.")
  }
  if (!"ETHNICITY" %in% names(df)) {
    stop("`df` must contain a column named 'ETHNICITY'.")
  }
  
  ethnicity_mapping <- list(
    White = c("A", "B", "C", "C2", "C3", "CA", "CB", "CC", "CD", "CE", "CF",
              "CG", "CH", "CJ", "CK", "CL", "CM", "CN", "CP", "CQ", "CR",
              "CS", "CT", "CU", "CV", "CW", "CX", "CY"),
    Mixed = c("D", "E", "F", "G", "GA", "GB", "GC", "GD", "GE", "GF"),
    Asian = c("H", "J", "K", "L", "LA", "LB", "LC", "LD", "LE", "LF", "LG",
              "LH", "LJ", "LK", "R"),
    Black = c("M", "N", "P", "PA", "PB", "PC", "PD", "PE"),
    Other = c("S", "SA", "SB", "SC", "SD", "SE")
  )
  
  code_to_group_map <- setNames(
    rep(names(ethnicity_mapping), lengths(ethnicity_mapping)),
    unlist(ethnicity_mapping)
  )
  
  df$ETHNICITY <- as.character(df$ETHNICITY)
  
  df$Grouped_Ethnicity <- code_to_group_map[df$ETHNICITY]
  
  return(df)
}

expected_output <- structure(list(
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
  actual_output <- group_ethnicity(random_patient_data)
  
  expect_equal(actual_output, expected_output)
})


df_merged <- av_patient_tumour_merge(random_patient_data, random_tumour_data)
df_merged

survival_days <- function(df) {              
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.")
  }
  
  required_columns <- c("DIAGNOSISDATEBEST", "VITALSTATUSDATE", "VITALSTATUS")
  if (!all(required_columns %in% colnames(df))) {
    stop(paste(
      "The input data frame must contain the following columns:",
      paste(required_columns, collapse = ", "),
      message("Please make sure to merge 'sim_av_patient' and 'sim_av_tumour'"),
      message("Use the function 'df_merged <- av_patient_tumour_merge(sim_av_patient,sim_av_tumour)' to merge the dataframes")
    ))
  }
  
  df$diff_date <- as.numeric(as.Date(df$VITALSTATUSDATE) - as.Date(df$DIAGNOSISDATEBEST))
  df$time_to_death <- ifelse(df$VITALSTATUS == "D", df$diff_date, NA_real_)
  df$status_OS <- ifelse(df$VITALSTATUS == "D", yes=1, no=0)
  df$Time_OS <- df$diff_date
  
  return(df)
}

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
