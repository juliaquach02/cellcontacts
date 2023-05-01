
#' Title: Computing cell-cell distances for one time point
#'
#' @description
#' For all possible cell pairs in one frame, this function checks whether the center
#' points of the cell pairs are in at least neighboring squares of the 2D grid.
#' If yes, the function computes the cell-cell distances.
#'
#' @param timepoint An integer that indicates the time point for which cell-cell
#' distances should be computed.
#' @param gridWidth The width of one square in the grid into which ROI centers have been assigned.
#' @param ROImap1 Hash map with tumor ROI names as keys and tumor ROI coordinates as values.
#' @param ROImap2 Hash map with T cell ROI names as keys and T cell ROI coordinates as values.
#' @param ROImapField1 Hash map with tumor ROI names as keys and assignment to grid as value.
#' @param ROImapField2 Hash map with T cell ROI names as keys and assignment to grid as value.
#'
#' @return A data frame with the cell-cell distances of all possible cell pairs at the chosen time points.
#' If the cell-cell distance is larger than the gridWidth, ">>[gridWidth]" will be inserted as value.
#'
#' @export
#'
#' @examples
compute_distTimepoint_wGrid <- function( timepoint,
                                         gridWidth = 100,
                                         ROImap1 = tumorROImap,
                                         ROImap2 = tcellROImap,
                                         ROImapField1 = tumorROImap_NamesToGrid,
                                         ROImapField2 = tcellROImap_NamesToGrid ){
  
  # Get all possible pairs for this time point
  pairs <- compute_pairs_timepoint( timepoint, ROImap1 = tumorROImap, ROImap2 = tcellROImap)
  
  # Return if there are no pairs at all
  if( length(pairs) == 0 ){ return( pairs )}
  
  # Rearrange pair list
  pairs_modified <- vector("list", length(pairs[,1]))
  
  for( i in 1:length(pairs[,1])){
    pairs_modified[[i]] <- pairs[i,]
  }
  
  st_polygon # put function without arguments here so that helper function finds it
  
  # Compute distances
  
  cell_distances <- sapply( pairs_modified, compute_cellDistance_wGrid,
                            gridWidth = 100,
                            ROImap1 = tumorROImap,
                            ROImap2 = tcellROImap,
                            ROImapField1 = tumorROImap_NamesToGrid,
                            ROImapField2 = tcellROImap_NamesToGrid )
  
  pairs$distances <- cell_distances
  
  return( pairs )
  
}


# Helper function to compute all possible cell pairs at one time point

compute_pairs_timepoint <- function( time, ROImap1 = tumorROImap, ROImap2 = tcellROImap ){
  
  # Cast time point to character
  time <- as.character( time )
  
  # Get Track names for this time point
  tumorROIs_timepoint <- ROImap1[[ time ]]
  tcellROIs_timepoint <- ROImap2[[ time ]]
  
  # Check whether there are any tumor and T cells for this time point
  if( any( tumorROIs_timepoint ==  "No value for this key" ) || any( tcellROIs_timepoint == "No value for this key")){
    pairs <- list()
  } else{
    # Compute all possible pairs for this time point
    pairs <- expand.grid( tumorROIs_timepoint, tcellROIs_timepoint )
  }
  
  return( pairs )
  
}



# Helper function to compute cell distances for one pair of cells

compute_cellDistance_wGrid <- function( pair,
                                        gridWidth = 100,
                                        ROImap1 = tumorROImap_center,
                                        ROImap2 = tcellROImap_center,
                                        ROImapField1 = tumorROImap_NamesToGrid,
                                        ROImapField2 = tcellROImap_NamesToGrid){
  
  # Get names
  tumorName <- as.character( pair[[1]] )
  tcellName <- as.character( pair[[2]] )
  
  # Check distance of center points
  
  tumorField <- ROImapField1[[ tumorName ]]
  tcellField <- ROImapField2[[ tcellName ]]
  
  abs_dist_fields <- abs( tumorField - tcellField )
  
  if( any( abs_dist_fields  > 1) ) {
    dist <- paste0(">>", gridWidth)
  } else{
    
    # Get coordinates
    tumorCoords <- tumorROImap[[ tumorName ]]
    tcellCoords <- tcellROImap[[ tcellName ]]
    
    # Transform coordinates to polygon
    tumorPolygon <- getPolygon( tumorCoords )
    tcellPOlygon <- getPolygon( tcellCoords )
    
    # Compute distance
    dist <- st_distance(x = tumorPolygon, y= tcellPOlygon, by_element = TRUE)
  }
  
  return( dist )
}


