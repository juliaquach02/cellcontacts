
#' Match ROI names to their frame number
#'
#' Creates data frame with ROI names and their respective frame number. 
#' Data are expected to be organized as follows:
#' One column contains the ROI names, which are the track names with 
#' incremented spot index in the format "Track_[id].[t]", 
#' and one column contains the frame number as integer.
#' This function selects the relevant columns and returns them as one data frame. 
#'
#' @param X the data frame from which the data are to be read from. Usually, 
#' the data was previously exported from TrackMate or Imaris and loaded as table from a .csv file.
#'
#' @return A data frame with ROI names in one column, each in the format "Track_[id]_[t]", 
#' and the frame number in which the respective ROI appears in a second column,
#' @export
#'
#' @examples
matchTrackNamesWithFrameNum <- function(X){
  
  tracksTxt <- X
  tracksTxt <- as.data.frame(tracksTxt)
  
  trackName <- tracksTxt$Label
  frameNum <- tracksTxt$Frame
  
  matchingIDsNames <- data.frame(TrackName = trackName, Frame = frameNum)
  
  # Replace "." with "_" in track name
  matchingIDsNames$TrackName <- gsub("[.]","-",matchingIDsNames$TrackName)
  
  # Result
  return(matchingIDsNames)
  
}
