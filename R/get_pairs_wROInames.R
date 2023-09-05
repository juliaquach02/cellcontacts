
#' Title
#'
#' @param x Data frame which contains cell-cell distances below distance threshold with columns pair, distance, and time point
#' @param minimumDuration Minimum duration of a 'cell contact'
#'
#' @return Data frame which contains only cell-cell distances which lasts for the minimum duration or longer
#' @export
#'
#' @examples
get_pairs_wROInames <- function( x, minimumDuration = 5){
  
  # Here every x is one of the dataframes for one pair.
  x <- x[ order( x$timePoint), ]
  
  # If there are no entries where contact = 'TRUE', 
  # return an empty dataframe
  if( !any( x$contact == TRUE ) ){
    return( data.frame() )
  }
  
  # Otherwise: compute # consecutive 'TRUE' in the 'contact' column
  consecutive <- rle( unlist( x$contact ) )
  
  # Convert into a dataframe so that we know for each "stretch" of contact/no contact
  # when it starts and ends
  df <- data.frame( 
    lengths = consecutive$lengths,
    contact = consecutive$values,
    endIndex = cumsum( consecutive$lengths )
  )
  
  df$startIndex = df$endIndex - df$lengths + 1
  df$startTime = x$t[ df$startIndex ]
  df$endTime = x$t[ df$endIndex ]
  df$duration = df$endTime - df$startTime
  
  # Keep only 'contact=TRUE' stretches of the minimum length; if there are none, return empty
  df <- df[ df$lengths >= minimumDuration & df$contact , ]
  if( nrow( df ) == 0 ){ return(data.frame()) }
  
  # Get the cell ROI names for validation
  
  tumourCells <- vector("list", length = nrow( df ) )
  TCells <- vector("list", length = nrow( df ))
  
  for( i in 1:nrow(df) ){
    tmp <- x[ x$timePoint >= df$startTime[[i]]  & x$timePoint <= df$endTime[[i]] , ]
    tumourCells[[i]] <- paste0( tmp$Var1, collapse=',' )
    TCells[[i]] <- paste0( tmp$Var2, collapse=',' )
  }
  
  # Select relevant columns and indicate the current pair we are looking at
  df <- df[ , c("startTime","endTime", "duration")]
  df$pair <- unique( x$pair )
  
  df$tumourCell <- tumourCells
  df$Tcell <- TCells
  
  return(df)
  
}
