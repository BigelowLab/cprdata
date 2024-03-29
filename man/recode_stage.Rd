% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stage.R
\name{recode_stage}
\alias{recode_stage}
\title{Recode values of stage to a uniform coding}
\usage{
recode_stage(x, lut = read_stage_lut(form = "vector"))
}
\arguments{
\item{x}{chr, vector of stage names}

\item{lut}{vector look up in the form of named vector}
}
\value{
character vector with zero or more elements recoded
}
\description{
Recode values of stage to a uniform coding
}
