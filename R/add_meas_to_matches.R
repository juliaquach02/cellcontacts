
#' Adding end point measurements to matches of tracks tp endpoint ROIs
#'
#' @param matches Data frame of pairs of tracked cell names and endpoint cells which have been matched to each other.
#' @param endPointMeasTxt Data frame with measurement results of endpoint ROIs, for instance from Fiji, loaded as .csv,
#'
#' @return Data frame with the following columns:
#' ROI names from the endpoint, from the imaging; the area, mean, min and max intensity of the endpoint ROI.
#' @export
#'
#' @examples
add_meas_to_matches <- function( matches, endPointMeasTxt ){
  
  # Cast and get names of matched endpoint and tracked ROIs
  matches$endpoint_cell <- as.integer( matches$endpoint_cell)
  matches <- matches[ order( matches$endpoint_cell), ]
  matches <- subset(matches, select = c( endpoint_cell, movies_cell ) )
  
  # Initialize data frame
  result <- data.frame(matrix(ncol=7 ,
                              dimnames=list(NULL, c("endpoint_cell", "movies_cell","X",
                                                    "Area", "Mean", "Min", "Max"))))
  
  # Get the right measurements for each endpoint ROIs
  for( i in 1:length( matches[,1]) ){
    index <- which( endPointMeasTxt$X == matches$endpoint_cell[[i]] )
    
    if( length(index) != 0){
      tmp <- cbind( matches[i,],  endPointMeasTxt[index,])
      result <- rbind( result, tmp)
    }
  }
  
  # Selected the columns for the output
  result <- subset(result, select = c( endpoint_cell, movies_cell,
                                       Area, Mean, Min, Max) )
  
  rownames( result ) <- NULL
  
  # Remove first row with "NA" entries
  result <- result[2:length(result[,1]),]
  
  return( result )
  
}

