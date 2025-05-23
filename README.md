
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simulacrumWorkflowR

simulacrumWorkflowR is a package developed to assist users of the
Simulacrum dataset in better preparing to use the dataset as a precursor
to accessing real patient data in the Cancer Administration System
(CAS).

The Simulacrum data is a synthetic version of the real patient data at
CAS. It is publicly available and can be used to create and test
analyses in R or STATA before executing them on the real data. However,
setting up Simulacrum requires creating a local Oracle database,
importing the data, and setting up an ODBC connection. To simplify this
process, the simulacrumWorkflowR package automates the setup of a
database within R and provides various utility functions for
preprocessing, query generation, and query testing.

# Installation

simulacrumWorkflowR may be installed using the following command:

``` r
# install.packages("devtools")
devtools::install_github("CLINDA-AAU/simulacrumWorkflowR",
dependencies = TRUE, force = TRUE) 
```

# Overview

The main functions of simulacrumWorkflowR is:

- Integrated SQL Environment: Leverages the SQLdf (Grothendieck, 2017)
  package to enable SQL queries directly within R, eliminating the need
  for external database setup and ODBC connections by creating a local
  SQLite temporary database within the R environment.

- Query Helper: Offers a collection of queries custom-made for the
  Simulacrum, for pulling and merging certain tables. Additionally, does
  the sqlite2oracle function assist in translating queries to be
  compatible with the NHS servers.

- Helper Tools: Offers a range of data preprocessing functions for
  cleaning, and preparing the data for analysis, ensuring data quality
  and consistency. Key functions include cancer type grouping, survival
  status, and detailed logging.

- Workflow Generator: Generates an R script with the complete workflow.
  Ensuring correct layout and the ability to integrate all the necessary
  code to obtain a workflow suitable for submission to the NHS and
  execution on the CAS database.

# The process

The process of using this package for getting access to the data at CAS
through Simulacrum is as following:

1)  Download the latest version of Simulacrum at:

``` r
library(simulacrumWorkflowR)
open_simulacrum_request()
#> Checking if the Simulacrum download page can be reached ...
#> URL seems reachable. Opening in browser ...
#> Complete the form for Simulacrum 2.1.0 and await the data retrieval to the email address used in the form.
```

Or at the link:
<https://simulacrum.healthdatainsight.org.uk/using-the-simulacrum/requesting-data/>

2)  Copy the directory path of the Simulacrum files on your local
    machine

3)  Use the package’s data loader function to load the files into R

4)  Utilize R to handle data preprocessing and analysis

5)  Save the complete workflow with the workflow generator function

6)  Send the Workflow to NHS and wait for the results

# Explanation of the workflow

The workflow is built around the SQLdf package where the user are able
to setup a invisible database in the span of seconds and fully
automated. Before the database is intialised, the user is required to
download the latest version of the Simulacrum (v2.1.0) data:
<https://simulacrum.healthdatainsight.org.uk/using-the-simulacrum/requesting-data/>
.

The latest Simulacrum data is formatted identically to the real CAS
data. Once downloaded, the read_simulacrum() function can automatically
load the CSV files as data frames in R:

``` r
dir <- "C:/Users/p90j/Documents/simulacrum_v2.1.0/Data"
# Automated data loading 
data_frames_lists <- read_simulacrum(dir, selected_files = c("sim_av_patient", "sim_av_tumour")) 
#> Reading: sim_av_patient
#> Reading: sim_av_tumour
#> Files successfully loaded!
#> Warning in read_simulacrum(dir, selected_files = c("sim_av_patient",
#> "sim_av_tumour")): Please refer to tables by their original names, capitalized
#> as presented (e.g., SIM_AV_PATIENT)
```

Access individual data frames as follows:

``` r
SIM_AV_PATIENT <- data_frames_lists$sim_av_patient
SIM_AV_TUMOUR <- data_frames_lists$sim_av_tumour
```

Once data frames are loaded, you can start writing queries. It’s
recommended to keep queries simple and handle data management in R. Use
the table_query_list function to access premade query templates. For
example, to merge tables:

``` r
query <- "SELECT *
FROM SIM_AV_PATIENT
INNER JOIN SIM_AV_TUMOUR ON SIM_AV_PATIENT.patientid = SIM_AV_TUMOUR.patientid;"
```

Execute queries with the sql_test() function:

``` r
query_result <- query_sql(query)
```

## SQLite to Oracle Query Translation

To accommodate differences between SQLite and Oracle queries, use the
sqlite2oracle() function:

``` r

query2 <- "select *
from SIM_AV_PATIENT
where age > 50
limit 500;"

sqlite2oracle(query2)
#> [1] "SELECT *\nFROM SIM_AV_PATIENT\nWHERE age > 50\nAND ROWNUM <= 500;"
```

Note: This function is built in `create_workflow()`

## Preprocessing Functions

simulacrumWorkflowR includes functions to simplify data preprocessing:

- ‘cancer_grouping’()
- ‘group_ethnicity()’
- ‘extended_summary()’
- ‘survival_days()’

## Workflow Generation

When data management and analysis are complete, use the workflow
generator function to produce an R script ready for submission to the
NHS:

``` r
create_workflow(
                         libraries = "library(dplyr)
                                      library(simulacrumWorkflowR)",
                         query = "SELECT *
                          FROM sim_av_patient
                          INNER JOIN sim_av_tumour ON sim_av_patient.patientid = sim_av_tumour.patientid
                          limit 500;",
                         data_management = "
                         # Run query on SQLite database
                          data <- cancer_grouping(query_result)

                          # Additional preprocessing
                          modified_data <- survival_days(data)
                          ",
                         analysis = "model = glm(AGE ~ STAGE_BEST + GRADE,  data=modified_data)",
                         model_results = "html_table_model(model)")
#> Created path ./Outputs
#> Workflow script created at: ./Outputs/workflow_20250523_1528.R
#> The workflow script is designed for execution on National Health Service (NHS). Local execution of this script is likely to fail due to its dependency on a database connection. The goal of this package is to generate a workflow file compatible with the NHS server environment, which eliminates the need for local database configuration. Assuming successful execution of all local operations, including library imports, data queries, data management procedures, analyses, and file saving, the generated workflow is expected to function correctly within the NHS server environment.
```

This workflow automates the process, ensuring easy integration and
preparation of your Simulacrum data.

In the event of an error on NHS servers while executing the analysis
pipeline, the `time_management` function and the base R `sink` will
generate a comprehensive log to facilitate seamless debugging.

# References

- Grothendieck G, (2017). Sqldf: Manipulate R Data Frames Using SQL.
  Link: ggrothendieck/sqldf: Perform SQL  
  Selects on R Data Frames

- Frayling L, Jose S. (2023) Simulacrum v2 User Guide. Health Data
  Insight. Link: Simulacrum-v2-User-Guide.pdf

- National Disease Registration Service (NDRS). (2023). Guide to using
  Simulacrum and Submitting code. Link:
  <https://digital.nhs.uk/ndrs/data/data-outputs/cancer-publications-and-tools/simulacrum/simulacrum-user-guide/developing-code-using-simulacrum-for-a-data-release-request>
