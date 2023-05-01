
#' Insert ROI names as keys and the ROI centers as value
#'
#' @param ROIs List of ROIs, usually loaded from a .zip file via the "read.ijzip" function.
#' @param ROImap  A hash map into which key and values should be inserted.
#'
#' @return There is no return value but the hash map will be edited.
#' @export
#'
#' @examples
insert_Hashmap_NamesToCenter <- function( ROIs, ROImap){
  
  names <- lapply( ROIs, getName)
  
  coordinates <- lapply( ROIs, getCoords)
  centers <- lapply( coordinates, computeCenter)
  
  # Insert keys and values in hash map
  ROImap[ names ] <- centers
  
}

# Helper function to compute center of ROI coordinates
computeCenter <- function( ROIcoords ){
  
  # Cast to matrix and close polygon
  ROIcoords <- as.matrix( ROIcoords )
  ROIcoords <- rbind( ROIcoords, ROIcoords[1,] )
  
  # Cast to polygon and compute center
  polygon <- st_polygon( list( ROIcoords ) )
  center <- st_centroid( polygon )
  
  return( center )
  
}



