
#' Adding the column "pair" to list of data frames
#'
#' @param cellDist List of data frames where each data frame represents one time point 
#' and has the following columns: names from cell population 1, names from cell population 2 and distance.
#'
#' @return List of data frames as above with one additional column "pair" 
#' where the names of the cell pairs are put into one string in the format "Track_[id1]-Track[id2]".
#' @export
#'
#' @examples
add_columnPair <- function( cellDist ){
  
  cellDist_edited <- lapply( cellDist, add_Pair )
  cellDist_edited <- cellDist_edited[ lapply( cellDist_edited, is.null) == FALSE]

  return( cellDist_edited)  
}

# Helper function to add the column pair for one time point

add_Pair <- function( cellDist_1timepoint){
  
  if( length( cellDist_1timepoint ) > 1){ # Check whether there are any pairs
    
    tumorName <- lapply( as.character( cellDist_1timepoint$Var1 ) , getTrackName )
    tcellName <- lapply( as.character( cellDist_1timepoint$Var2 ) , getTrackName  )
    
    cellDist_1timepoint$pair <- paste0( tumorName, "-", tcellName)
    
  } else{
    
    cellDist_1timepoint <- NULL
  }
  
  return( cellDist_1timepoint )
}


# Helper function to get the track name without the time point

getTrackName <- function( name ){
  
  splitName <- strsplit(name, "-")
  trackName <- splitName[[1]][[1]]
  
  return(trackName)
}
