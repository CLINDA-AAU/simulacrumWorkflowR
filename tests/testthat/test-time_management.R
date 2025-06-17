library(testthat)

test_that("compute_time_limit correctly identifies time within limit and produces expected output", {
  test_start_time <- as.POSIXct("2025-01-01 10:00:00", tz = "UTC")
  test_end_time <- as.POSIXct("2025-01-01 11:00:00", tz = "UTC")
  test_limit_hours <- 3

  expect_message(
  {
    result <- compute_time_limit(test_start_time, test_end_time, time_limit_hours = test_limit_hours)
  },
      regexp = "Total Execution Time:.*The time is within the three-hour threshold set by the NHS.",
      fixed = FALSE
  ) |>
  expect_warning(
      regexp = "Please note that the processing power of NHS servers and your local machine may vary significantly.",
      fixed = FALSE
  ) |>
  expect_warning(
      regexp = "Please also take into account the time required for the NDRS analyst",
      fixed = FALSE
  )
  
  expect_true("execution_time" %in% names(result))
  expect_true("time_limit_hours" %in% names(result))
  expect_true("message" %in% names(result))
  
  expect_equal(as.numeric(result$execution_time, units = "mins"), 60)
  expect_equal(result$time_limit_hours, test_limit_hours)
  
  expect_match(result$message, "The time is within the three-hour threshold set by the NHS.", fixed = FALSE)
})

test_that("compute_time_limit handles time outside limit", {
  test_start_time <- as.POSIXct("2025-01-01 09:00:00", tz = "UTC")
  test_end_time <- as.POSIXct("2025-01-01 13:00:00", tz = "UTC")
  test_limit_hours <- 3
  
  expect_warning(
    {
      result_outside <- compute_time_limit(test_start_time, test_end_time, time_limit_hours = test_limit_hours)
    },
    regexp = "Total Execution Time:.*Please be aware that this analysis time have exceeded the three-hour threshold of NHS.",
    fixed = FALSE
  )
})
