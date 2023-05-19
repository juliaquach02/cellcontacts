
#' Plotting matches of tracked ROIs to end point ROIs
#'
#' @param matches Data frame with ROI name from tracks in one column and 
#' matched tumour ROI name from endpoint in second column.
#' @param tumorROImap Hash map with tracked ROI names as keys and ROI coordinates as values.
#' @param endpointROImap Hash map with endpoint ROI names as keys and ROI coordinates as values.
#' @param cols Vector with colors. The default is set to "brewer.pal( 10,'Spectral')".
#' @param xlim Width of the frame.
#' @param ylim Hight of the frame.
#'
#' @return There is no return value but a plot will be displayed.
#' @export
#'
#' @examples
plot_matches <- function( matches, tumorROImap, endpointROImap,
                         cols = brewer.pal( 10,'Spectral'),
                         xlim = c(0,550), ylim = c(0,550) ){
  # Set margins of plot
  par(mar=c(10, 6, 3, 6) + 0.1)
  
  # Create empty plot
  plot(NA,  xlab = "x-direction", ylab = "y-direction", 
       xlim = xlim,
       ylim = ylim,
       main = "Matched ROIs")
  
  # Add matched ROIs
  numColours <- length( cols )
  
  for(i in 1:length( matches$movies_cell )){
    
    col_Index <- i %% numColours + 1
    
    movie_cell_name <- as.character( matches$movies_cell[[i]] )
    movie_polygon <- getPolygonFromName( movie_cell_name, ROImap = tumorROImap )
    plot( movie_polygon, fill = NA, border= cols[[col_Index]] , add = TRUE )
    
    endpoint_cell_name <-  as.character( matches$endpoint_cell[[i]] )
    endpoint_polygon <- getPolygonFromName( endpoint_cell_name, ROImap = endpointROImap )
    plot( endpoint_polygon, fill = NA, border= cols[[col_Index]] , add = TRUE )
    
  }
  
}
