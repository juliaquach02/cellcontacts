

#' Insert ROI names as keys and ROI coordinates as values into hash map
#'
#' @param ROIs List of ROIs, usually loaded from a .zip file via the "read.ijzip" function.
#' @param ROImap A hash map into which key and values should be inserted.
#'
#' @return There is no return value but the hash map will be edited.
#' @export
#'
#' @examples
insert_Hashmap_NamesToCoords <- function( ROIs, ROImap ){
  
  ROInames <- sapply( ROIs, getName, simplify = FALSE )
  ROIcoords <- sapply( ROIs, getCoords, simplify = FALSE )
  
  # Insert keys and values in hash map
  ROImap[ ROInames ] <- ROIcoords
}

# Help functions
getCoords <- function( ROI ){
  return( ROI$coords )
}

getName <- function( ROI ){
  return( ROI$name )
}

