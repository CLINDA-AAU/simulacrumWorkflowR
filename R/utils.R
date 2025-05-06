#' Merge of patient and tumour df
#' 
#' @description
#' A simple merge function for gathering the two dataframes `sim_av_patient` and `sim_av_tumour`. 
#' Dplyr is utilized to keep only one gender column as both datasets contains a gender column.
#' 
#' @import dplyr
#' 
#' @param df1 a dataframe to be merged with df2. df1 is default set to `sim_av_patient`.
#' @param df2 a dataframe to be merged with df1. df2 is default set to `sim_av_tumour`.
#' 
#' 
#' @return a merged dataframe
#' 
#' @export

av_patient_tumour_merge <- function(df1 = sim_av_patient, df2 = sim_av_tumour){
  message("Merging `sim_av_patient` and `sim_av_tumour`...")
  merged_df <- merge(df1, df2, by = "PATIENTID", all = TRUE)
  
  merged_df <- merged_df %>%                  
    dplyr::select(-GENDER.x) %>%         
    dplyr::rename(GENDER = GENDER.y) %>% 
    dplyr::arrange(PATIENTID)            
  
  return(merged_df)
}



#' Generate an Extended Summary of a Data Frame
#'
#' @description
#' Summarizes a data frame, including missing values, unique values, and column classes.
#'
#' @param df A data frame to summarize.
#' 
#'
#' @return A data frame summarizing:
#' - Column names
#' - Number of missing values
#' - Number of unique values
#' - Data class of each column
#' @export
#' 
#' @examples 
#' summary_df <- extended_summary(sim_av_patient)

extended_summary <- function(df) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.")
  }
  df_summary <- data.frame(
    Columns = colnames(df),
    Missing_Values = sapply(df, function(x) sum(is.na(x))),
    Unique_Values = sapply(df, function(x) length(unique(x))),
    Class = sapply(df, class)
  )
  return(df_summary)
}

#' Create a new directory if it does not exist.
#'
#' This function creates a directory at the specified path if it does not already exist. The default name is "Outputs". To illustrate the folder is meant for various outputs of the package.
#' There is also optional verbose output to inform the user about the action taken. 
#'
#' @param dir_path A character string defining a path of the directory to create. Defaults is "Outputs".
#' @param verbose A logical value to decide if there should be a printed messages about the directory creation process. Defaults is TRUE.
#'
#' @return invisible return of the `dir_path`
#'
#' @export

create_dir <- function(dir_name = "./Outputs", verbose = TRUE) {
  if (!is.character(dir_name)) {
    stop("`dir_name` needs to be a string")
  }
  if (!is.logical(verbose)) {
    stop("`verbose` needs to be a logical value")
  }
  
  if (!dir.exists(dir_name)) {
    dir.create(dir_name, recursive = TRUE)
    if (verbose) {
      message(paste0("Created path ", dir_name))
    }
  } else if (verbose) {
    message(paste0("Path ", dir_name, " already exists"))
  }
  
  invisible(dir_name)
}


#' Open Simulacrum Data Request Page
#' 
#' @description Opens the Simulacrum data download webpage, checks if it can be reached and prints instructions.
#' @examples
#' open_simulacrum_request()
#' @export
#' 
#' @importFrom RCurl url.exists
open_simulacrum_request <- function() {
  simulacrum_url <- "https://simulacrum.healthdatainsight.org.uk/using-the-simulacrum/requesting-data/"
  
  message("Checking if the Simulacrum download page can be reached ...")
  
  if (url.exists(simulacrum_url)) {
    
    message("URL seems reachable. Opening in browser ...")
    
    browseURL(simulacrum_url)
    
    message("Complete the form for Simulacrum 2.1.0 and await the data retrieval to the email address used in the form.")
    
  } else {
    warning("Warning: Could not confirm existence of URL '", simulacrum_url,
            "'. The page may not exist, there might be a network issue, or the simple check failed.")
  }
}
