#' Create Workflow Script
#'
#' @description
#' This function generates a complete R workflow script for use with NHS data pipelines. It compiles code chunks for library setup, query execution, data management, analysis, and model results into a single script. 
#'
#' @details
#' The `create_workflow` function accepts chunks of code as input parameters, processes them, and integrates them into a predefined workflow template. The template includes sections for library setup, database connections, querying, data management, analysis, and result handling. The generated script also contains time monitoring to evaluate the total execution time to ensure it is within the three hour limit of the servers at NHS.
#'
#' The `sqlite2oracle` function is used to convert SQL queries from SQLite syntax to Oracle syntax.
#'
#' @param file_path A character string specifying the file path where the workflow script will be saved. Timestamp is added to prevent overwritten.
#' @param libraries A character string containing R library calls.
#' @param query A character string containing an SQL query to execute. The query is automatically processed using `sqlite2oracle` for Oracle compatibility.
#' @param data_management A character string with data preprocessing and management steps.
#' @param analysis A character string with data analysis steps.
#' @param model_results A character string containing code to process and export model results.
#' @param logging A boolen value where the user can decide if there should be logging in the complete workflow file. The logging consist of the `sink` function and the `compute_time_limit` function. 
#'
#' @return None. The function writes the generated workflow script to the specified file path and outputs a message with the location of the created script.
#'
#' @importFrom simulacrumWorkflowR sqlite2oracle
#' @importFrom simulacrumWorkflowR create_dir
#' @importFrom simulacrumWorkflowR start_time
#' @importFrom simulacrumWorkflowR stop_time
#' @importFrom simulacrumWorkflowR compute_time_limit
#' @importFrom DBI dbConnect dbGetQuery dbDisconnect dbIsValid
#'
#' @export
#'
#' @examples
#' # Generate a workflow script with minimal input
#' create_workflow(
#'   libraries = "library(dplyr)",
#'   query = "SELECT * FROM sim_av_patients LIMIT age > 50;",
#'   data_management = "df <- cancer_grouping(df)",
#'   analysis = "model <- glm(Y ~ x1 + x2 + x3, data=df",
#'   model_results = "write.csv(model, 'results.csv')"
#' )
create_workflow <- function(
    file_path = paste0("workflow_", format(Sys.time(), "%Y%m%d_%H%M"), ".R"),
    output_dir = "./Outputs",
    libraries = "",
    query = "",
    data_management = "",
    analysis = "",
    model_results = "",
    logging = TRUE
) 
{
  clean_chunk <- function(chunk) {
    if (is.null(chunk) || chunk == "") 
      return("")
    
    cleaned_lines <- trimws(strsplit(chunk, "\n")[[1]])
    cleaned_lines <- cleaned_lines[cleaned_lines != ""]
    paste(cleaned_lines, collapse = "\n")
  }
  
  libraries <- clean_chunk(libraries)
  query <- clean_chunk(query)
  data_management <- clean_chunk(data_management)
  analysis <- clean_chunk(analysis)
  model_results <- clean_chunk(model_results)
  
  if (query != "") {
    query <- gsub("SIM_", "", query)
    query <- gsub("sim_", "", query)
    
    query <- sqlite2oracle(query)
  }
  
  create_dir(output_dir)
  
  if (logging == TRUE) {
    logging_top <- sprintf("
# logging ----------------------------------------------------------
start <- start_time()
report <- file(file.path('%s', 'console_log_test.txt'), open = 'wt')
sink(report, type = 'output')
sink(report, type = 'message')", output_dir)
  } else {
    logging_top <- ""
  }
  
  if (logging == TRUE) {
    logging_bottom = "
stop <- stop_time()
compute_time_limit(start, stop)
sink()
sink()" 
  } else {
    logging_bottom <- ""
  }
  
  workflow_template <- "
# Complete Workflow for NHS  
{LOGGING_TOP}
# Libraries ----------------------------------------------------------
library(knitr)
library(DBI)
library(odbc)
{LIBRARIES}
# ODBC --------------------------------------------------------------------
my_oracle <- dbConnect(odbc::odbc(),
                       Driver = \"\",
                       DBQ = \"\", 
                       UID = \"\",
                       PWD = \"\",
                       trusted_connection = TRUE)
# Query ----------------------------------------------------------
query1 <- \"{QUERY}\"
query_result <- dbGetQuery(my_oracle, query1)
# Data Management ----------------------------------------------------------
{DATA_MANAGEMENT}
# Analysis ----------------------------------------------------------
{ANALYSIS}
# Model Results ----------------------------------------------------------
{MODEL_RESULTS}
{LOGGING_BOTTOM}
"
  
  workflow_content <- workflow_template
  workflow_content <- gsub("\\{LOGGING_TOP\\}", logging_top, workflow_content)
  workflow_content <- gsub("\\{LOGGING_BOTTOM\\}", logging_bottom, workflow_content)
  workflow_content <- gsub("\\{LIBRARIES\\}", libraries, workflow_content)
  workflow_content <- gsub("\\{QUERY\\}", query, workflow_content)
  workflow_content <- gsub("\\{DATA_MANAGEMENT\\}", data_management, workflow_content)
  workflow_content <- gsub("\\{ANALYSIS\\}", analysis, workflow_content)
  workflow_content <- gsub("\\{MODEL_RESULTS\\}", model_results, workflow_content)
  
  workflow_content <- gsub("\\n{3,}", "\n\n", workflow_content)
  
  output_file_path <- file.path(output_dir, file_path)
  
  tryCatch({
    writeLines(workflow_content, output_file_path)
    message("Workflow script created at: ", output_file_path)
  }, error = function(e) {
    warning(paste("Failed to write workflow file:", e$message))
  })
  
  message("The workflow script is designed for execution on National Health Service (NHS). Local execution of this script is likely to fail due to its dependency on a database connection. The goal of this package is to generate a workflow file compatible with the NHS server environment, which eliminates the need for local database configuration. Assuming successful execution of all local operations, including library imports, data queries, data management procedures, analyses, and file saving, the generated workflow is expected to function correctly within the NHS server environment.")  
  
  # Return the path for chaining or verification
  return(invisible(output_file_path))
}