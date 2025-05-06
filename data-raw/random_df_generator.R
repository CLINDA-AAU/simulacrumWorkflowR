library(simulacrumWorkflowR)

dir <- "C:/Users/p90j/Documents/simulacrum_v2.1.0/Data"
data_frames_lists <- read_simulacrum(dir) 


data_frames_to_process <- list(
  sim_av_gene = data_frames_lists$sim_av_gene,
  sim_rtds_combined = data_frames_lists$sim_rtds_combined,
  sim_rtds_episode = data_frames_lists$sim_rtds_episode,
  sim_rtds_exposure = data_frames_lists$sim_rtds_exposure,
  sim_rtds_prescription = data_frames_lists$sim_rtds_prescription,
  sim_sact_cycle = data_frames_lists$sim_sact_cycle,
  sim_sact_drug_detail = data_frames_lists$sim_sact_drug_detail,
  sim_sact_outcome = data_frames_lists$sim_sact_outcome,
  sim_sact_regimen = data_frames_lists$sim_sact_regimen # Assuming this was the intended 9th dataframe
)

zero_dataframe_columns <- function(df) {
  zero_df <- as.data.frame(matrix(0, nrow = nrow(df), ncol = ncol(df)))
  
  colnames(zero_df) <- colnames(df)
  
  return(zero_df)
}

zeroed_dataframes_list <- list()

for (df_name in names(data_frames_to_process)) {
  df <- data_frames_to_process[[df_name]]
  
  df_head <- head(df, 10)
  
  zeroed_df <- zero_dataframe_columns(df_head)
  
  zeroed_dataframes_list[[df_name]] <- zeroed_df
  
}


output_dir <- "C:/Users/p90j/Documents/simulacrumWorkflowR/inst/extdata/minisimulacrum/"



for (df_name in names(zeroed_dataframes_list)) {
  zeroed_df <- zeroed_dataframes_list[[df_name]]
  
  output_csv_path <- paste0(output_dir, df_name, ".csv")
  
  write.csv(zeroed_df, file = output_csv_path, row.names = FALSE)
  
}
