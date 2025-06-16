library(testthat)

test_that("sqlite2oracle converts a simple SELECT with LIMIT correctly", {
  sqlite_query <- "select * from MY_table limit 10"
  
  expected_oracle_query <- "SELECT * FROM MY_TABLE WHERE ROWNUM <= 10;"
  
  actual_oracle_query <- sqlite2oracle(sqlite_query)
  
  expect_equal(actual_oracle_query, expected_oracle_query)
})