
#' Adding the column "timePoint" to list of data frames
#'
#' @param cellDist_1timepoint Data frame with at least the columns columns: 
#' names from cell population 1 and names from cell population 2.
#' @param tumour_trackName_frameNum A data frame with ROI names in one column, each in the format "Track_[id]_[t]", 
#' and the frame number/time point in which the respective ROI appears in a second column,
#'
#' @return The data frame above with an additional column "timePoint" 
#' showing the time point at which the respective cell ROIs appear.
#' @export
#'
#' @examples
add_columnTimepoint <- function( cellDist_1timepoint, tumour_trackName_frameNum ){
  
  # The time point should be identical for all pairs in the data frame
  cellDist_1timepoint_fristRow <- cellDist_1timepoint[1,]
  
  # Get the track name and with the track name the frame number.
  trackName <- as.character( cellDist_1timepoint_fristRow$Var1 )
  
  index <- which( tumour_trackName_frameNum$TrackName == trackName)
  
  timePoint <- tumour_trackName_frameNum[index,]$Frame
  
  cellDist_1timepoint$timePoint <- timePoint
  
  return( cellDist_1timepoint )
}



