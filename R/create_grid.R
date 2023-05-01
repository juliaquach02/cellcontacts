#' Helper function to create a 2D grid
#' 
#' @details The grid should be slightly bigger than the dimensions of the frame 
#' as cell centers could lay outside the grid.
#'
#' @param xlim x-dimensions of the grid in the format "c([start], [end])"
#' @param ylim y-dimensions of the grid in the format "c([start], [end])"
#' @param dim Number of rows/columns in the grid.
#'
#' @return Data frame representing the cells of a grid with the selected dimensions.
#' @export
#'
#' @examples
create_grid <- function( xlim, ylim, dim = 5){
  
  x <- list()
  y <- list()
  
  xWidth <- xlim[[2]] - xlim[[1]]
  yWidth <- ylim[[2]] - ylim[[1]]
  
  for( i in 1: (dim+1)){
    x[i] <- (i-1) * xWidth / dim + xlim[[1]]
    y[i] <- (i-1) * yWidth / dim + ylim[[1]]
  }
  
  grid <- cbind( x, y)
  
  return( grid)
}
