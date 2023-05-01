
#' Insert frame number as keys and track names as values into hash map
#'
#' @param matchingIDsNames A data frame with ROI names in one column
#' and the frame number in which the respective ROI appears in a second column,
#' @param ROImap A hash map into which key and values should be inserted.
#'
#' @return There is no return value but the hash map will be edited.
#' @export
#'
#' @examples
insert_Hashmap_FrameNumToNames <- function( matchingIDsNames, ROImap = ROImap ){
  
  # Split the data frame with track names and frame number by the frame number
  matchingIDsNames_byFrame <- split( matchingIDsNames, matchingIDsNames$Frame)
  
  # Insert track names for each time point
  invisible( lapply( matchingIDsNames_byFrame, helperf_insert_Hashmap_FrameNumToNames, ROImap = ROImap) )
  
}

# Helper function to insert track names into hash map for one time point
helperf_insert_Hashmap_FrameNumToNames <- function( matchingIDsNames_byFrame_1, ROImap = ROImap ){
  
  frameNum <- as.character( matchingIDsNames_byFrame_1$Frame[[1]] )
  
  trackNames <- matchingIDsNames_byFrame_1$TrackName
  
  ROImap[[ frameNum ]] <- trackNames
  
}
