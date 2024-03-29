% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/insert_Hashmap_FrameNumToNames.R
\name{insert_Hashmap_FrameNumToNames}
\alias{insert_Hashmap_FrameNumToNames}
\title{Insert frame number as keys and track names as values into hash map}
\usage{
insert_Hashmap_FrameNumToNames(matchingIDsNames, ROImap = ROImap)
}
\arguments{
\item{matchingIDsNames}{A data frame with ROI names in one column
and the frame number in which the respective ROI appears in a second column,}

\item{ROImap}{A hash map into which key and values should be inserted.}
}
\value{
There is no return value but the hash map will be edited.
}
\description{
Insert frame number as keys and track names as values into hash map
}
