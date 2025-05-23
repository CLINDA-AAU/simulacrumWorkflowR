
# Complete Workflow for NHS  

# logging ----------------------------------------------------------
start <- start_time()
report <- file(file.path('./Outputs', 'console_log_test.txt'), open = 'wt')
sink(report, type = 'output')
sink(report, type = 'message')
# Libraries ----------------------------------------------------------
library(knitr)
library(DBI)
library(odbc)
library(dplyr)
library(simulacrumWorkflowR)
# ODBC --------------------------------------------------------------------
my_oracle <- dbConnect(odbc::odbc(),
                       Driver = "",
                       DBQ = "", 
                       UID = "",
                       PWD = "",
                       trusted_connection = TRUE)
# Query ----------------------------------------------------------
query1 <- "SELECT *
FROM sim_av_patient
INNER JOIN sim_av_tumour ON sim_av_patient.patientid = sim_av_tumour.patientid
WHERE ROWNUM <= 500;"
data <- dbGetQuery(my_oracle, query1)
# Data Management ----------------------------------------------------------
# Run query on SQLite database
data <- cancer_grouping(query_result)
# Additional preprocessing
modified_data <- survival_days(data)
# Analysis ----------------------------------------------------------
model = glm(AGE ~ STAGE_BEST + GRADE,  data=modified_data)
# Model Results ----------------------------------------------------------
html_table_model(model)

stop <- stop_time()
compute_time_limit(start, stop)
sink()
sink()

