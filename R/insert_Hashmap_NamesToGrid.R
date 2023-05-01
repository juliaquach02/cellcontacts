

#' Insert ROI names as keys and assignment to cells in grid as values into hash map
#'
#' @param ROIs List of ROIs, usually loaded from a .zip file via the "read.ijzip" function.
#' @param ROImap A hash map into which key and values should be inserted.
#' @param grid Data frame representing a grid. ROI centers are assigned into cells of this grid.
#'
#' @return There is no return value but the hash map will be edited.
#' @export
#'
#' @examples
insert_Hashmap_NamesToGrid <- function( ROIs, ROImap, grid){
  
  dim <- length( grid[,1])
  
  names <- lapply( ROIs, getName)
  coordinates <- lapply( ROIs, getCoords)
  centers <- lapply( coordinates, computeCenter)
  
  gridAssignment <- lapply( centers, assignToGrid, grid = grid, dim = dim)
  
  # Insert keys and values in hash map
  ROImap[ names ] <- gridAssignment
  
}

# Helper function to assign ROI centers into grid
assignToGrid <- function( center, grid, dim ){
  
  xCoord <- center[[1]]
  yCoord <- center[[2]]
  
  for( i in 1: (dim - 1)) {
    
    if( grid[[i,1]] <= xCoord && xCoord <= grid[[i+1,1]] ){
      # assign grid number in x direction
      x <- i+1
      break
    }
  }
  
  for( j in 1: (dim-1)){
    
    if( grid[[j,2]] <= yCoord && yCoord <= grid[[j+1,2]] ){
      # assign grid number in x direction
      y <- j+1
      break
    }
  }
  
  gridField <- cbind( x, y )
  
  return( gridField )
  
}
