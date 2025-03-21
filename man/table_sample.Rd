% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/preprocessing.R
\name{table_sample}
\alias{table_sample}
\title{Random Sample of a Data Frame}
\usage{
table_sample(df, n = 1000)
}
\arguments{
\item{df}{A data frame to sample from.}

\item{n}{An integer specifying the number of rows to sample. Default is 1000.}
}
\value{
A data frame containing the sampled rows.
}
\description{
Takes a random sample of rows from a data frame.
}
\examples{
sample_df <- table_sample(sim_av_patient, 500)
}
