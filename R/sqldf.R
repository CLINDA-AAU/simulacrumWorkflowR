#' Execute an SQL Query on a Data Frame
#'
#' @description
#' This function allows you to execute SQL queries directly on data frames using the `sqldf` package.
#' 
#' @details
#' The `sqldf` package provides a convenient interface for running SQL queries on R data frames. 
#' Behind the scenes, `sqldf` creates a temporary SQLite database, loads the specified data frames into it, 
#' executes the SQL query, retrieves the results as an R data frame, and then deletes the database. 
#' The process enables the user test SQL without having to setup database or connection between R and the database..
#' 
#' This function is particularly useful for people who wants to use Simulacrum to access the CAS data. 
#' As the only setup needed is to install the package in R.  
#' 
#' @param query A character string containing the SQL query to execute.
#'
#' @return A data frame resulting from the SQL query.
#' 
#' @export
#' 
#' @importFrom sqldf sqldf
query_sql <- function(query) {
  if(!is.character(query))
    stop("The function must contain a string")
  result_df <- sqldf(query, stringsAsFactors = FALSE)
  
  warning("To maintain consistency with create_workflow(), consider assigning the output of query_sql() to a variable named 'query_result'. This aligns with the example workflow and streamlines the workflow.")
  
  return(result_df)
  
}


