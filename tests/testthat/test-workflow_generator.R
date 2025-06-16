library(testthat)


test_that("creates the specified file in the specified directory", {
  test_output_dir <- file.path(tempdir(), paste0("test_dir_", sample(100, 1)))
  dir.create(test_output_dir, showWarnings = FALSE, recursive = TRUE)
  
  on.exit(unlink(test_output_dir, recursive = TRUE), add = TRUE)
  
  test_file_name <- "specific_workflow_file.R"
  expected_file_path <- file.path(test_output_dir, test_file_name)

  suppressMessages(
    create_workflow(
      file_path = test_file_name,   
      output_dir = test_output_dir 
    )
  )
  
  expect_true(file.exists(expected_file_path))
})
