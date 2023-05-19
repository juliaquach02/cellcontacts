
#' Filtering data frame with cell-cell distances for cell-cell contacts
#'
#' @param x A data frame containing the columns "pair", "distance" and "contact". 
#' The latter should be a column with TRUE/FALSE entries. The entries of the "pair"
#' column should be in the formal "[name of tumor cell]-[name of T cell]"
#' @param minimumDuration  The minimum duration of a contact
#'
#' @return A data frame containing the columns "pair", "distance", "startTime", "endTime", "duration", "tumorCell", "TCell"
#' @export
#'
#' @examples
get_pairs <- function( x, minimumDuration = 5){
  
  # Here every x is one of the dataframes for one pair.
  # the time column should be sorted in ascending order:
  x <- x[ order( x$t), ]
  
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
  
  # Select relevant columns and indicate the current pair we are looking at
  df <- df[ , c("startTime","endTime", "duration")]
  df$pair <- unique( x$pair )
  
  tmp <- str_split(  unique( x$pair ), "-")[[1]]
  df$tumorCell <- tmp[[1]]
  df$Tcell <- tmp[[2]]
  return(df)
  
}
