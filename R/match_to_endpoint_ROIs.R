
#' Match tracked tumour cells to endpoint tumour cells
#'
#' @param endPointROIs List of ROIs at the last time point, usually loaded from a .zip file via the "read.ijzip" function.
#' @param endpointROImap Hash map of endpoint ROI names as keys and endpoint ROI coordinates as values.
#' @param tumorROImap Hash map of names of tracked ROIs as keys and their coordinates as values.
#' @param tumorROImap_center Hash map of names of tracked ROIs as keys and their center as values.
#' @param tumorROImap_NamesToGrid Hash map of names of tracked ROIs as keys and their assignment to grid as values.
#'
#' @return Data frame of pairs of tracked cell names and endpoint cells which have been matched to each other.
#' @export
#
#' @examples
match_to_endpoint_ROIs <- function( endPointROIs, endpointROImap, tumorROImap, tumorROImap_center, tumorROImap_NamesToGrid ){
  
  # Get tumor cell names and polygons at last time point of the movie
  
  time <- as.character( tumorROImap[[ "lastTimepoint" ]] )
  
  tumorCellNames <- as.data.frame( tumorROImap[[ time ]] )
  tumorCellNames <- tumorCellNames[,1]
  
  tumorPolygons <- lapply( tumorCellNames, getPolygonFromName, ROImap = tumorROImap )
  
  # Compute all possible pairs of ROIs
  
  endPointROIs_names <- lapply( endPointROIs, getName)
  
  pairs <- expand.grid( tumorCellNames, endPointROIs_names )
  colnames( pairs ) <- c( "movies_cell", "endpoint_cell")
  
  # Test all possible pairs
  
  numVertices <- 32 # Number of vertices of a polygon
  match <- vector( "list", length = length( pairs ))
  
  for( i in 1:length(pairs[,1]) ){ # Go through all possible pairs
    
    # Get grid position of tracked cells
    cell_movie_name <- as.character( pairs[i,1] )
    cell_movie_field <- tumorROImap_NamesToGrid[[ cell_movie_name ]]
    
    # Get grid position of endpoint cells
    cell_endpoint_name <-  as.character( pairs[i,2] )
    cell_endpoint_field <- tumorROImap_NamesToGrid[[ cell_endpoint_name ]]
    
    match[[i]] <- FALSE
    
    # Check whether cell pair come at least from neighbouring grid.
    if( !any( abs( cell_movie_field[1,] - cell_endpoint_field[1,] ) > 1 )) {
      
      # Get center point of tumor ROI
      movie_centerPoint <- tumorROImap_center[[ cell_movie_name ]]
      
      movie_centerPoint_x <- movie_centerPoint[[1]]
      movie_centerPoint_y <- movie_centerPoint[[2]]
      
      # Get polygon of endpoint
      endpoint_coords <- endpointROImap[[ pairs[i,2][[1]] ]]
      
      # Add vertex to close the endpoint polygon
      endpoint_coords <- rbind( endpoint_coords, endpoint_coords[ numVertices,])
      
      
      # Check whether center point lies within endpoint ROI
      endpoint_xCoord <- endpoint_coords[,1]
      endpoint_ycoord <- endpoint_coords[,2]
      pointInPolygon <- point.in.polygon( movie_centerPoint_x, movie_centerPoint_y, endpoint_xCoord, endpoint_ycoord)
      
      if( pointInPolygon != 0 ){ # If the center point is not outside the polygon
        match[[i]] <- TRUE
      }
      
    }
    
  }
  
  # Add column "match" for all possible pairs
  pairs$match <- match
  
  # Get matches
  matches <- pairs[ pairs$match == TRUE, ]
  
  return( matches )
  
}

# Helper function to get polygon from its namedev
getPolygonFromName <- function( name, ROImap = tumorROImap){

  polygon <- getPolygon( ROImap[[ name ]] )
  
  return( polygon )
}


# Helper function to get polygon from ROI coordinates
getPolygon <- function( ROIcoords ){
  
  st_polygon
  
  ROIcoords <- as.matrix( ROIcoords )
  ROIcoords <- rbind( ROIcoords, ROIcoords[1,] )
  polygon <- st_polygon( list( ROIcoords ) )
  
  return( polygon )
}


