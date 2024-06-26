% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_contacts.R
\name{check_contacts}
\alias{check_contacts}
\title{Checking whether the cell distances are below threshold}
\usage{
check_contacts(cellDist_1timepoint, distThresh = Inf)
}
\arguments{
\item{cellDist_1timepoint}{Data frame containing one column "distances"}

\item{distThresh}{Distance threshold for computing contacts.}
}
\value{
Data frame with one additional column "contact" with TRUE/FALSE entries.
}
\description{
Checking whether the cell distances are below threshold
}
