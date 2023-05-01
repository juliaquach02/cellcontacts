#' Checking whether the cell distances are below threshold
#'
#' @param cellDist_1timepoint Data frame containing one column "distances"
#' @param distThresh Distance threshold for computing contacts.
#'
#' @return Data frame with one additional column "contact" with TRUE/FALSE entries.
#' @export
#'
#' @examples
check_contacts <- function( cellDist_1timepoint, distThresh = Inf ){
  
  cellDist_1timepoint$contact <- lapply( cellDist_1timepoint$distances, check_contact, distThresh = distThresh)
  
  return( cellDist_1timepoint )
}


check_contact <- function( dist, distThresh = Inf){
  
  contact <- FALSE
  
  if( dist == ">>100"){
    return( contact )
  }
  
  dist <- as.double( dist )
  distThresh <- as.double( distThresh )
  
  if( dist <= distThresh){
    contact <- TRUE
  }
  
  return( contact )
}
