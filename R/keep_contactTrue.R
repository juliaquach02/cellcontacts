
#' Keeping only cell pairs with distance below threshold.
#'
#' @param cellDistances Data frame with column "distances"
#'
#' @return Data frame as input but with additional column "contact" with TRUE/FALSE entries.
#' @export
#'
#' @examples
keep_contactTrue <- function( cellDistances ){
  
  if( length( cellDistances$contact ) != 0){
    cellDistances <- cellDistances[ cellDistances$contact == TRUE, ]
  } else{
    return( NULL )
  }
  
  return( cellDistances )
}
