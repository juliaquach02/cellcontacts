
#' Compute cell contact duration and number of contacts
#'
#' @param contactList List of data frames. Each data frame represents one cell-cell contacts
#' with the columns "pair", "distance", "startTime", "endTime", "duration", "tumorCell", "TCell".
#' @param secPerFrame Time between each frame in seconds.
#'
#' @return A data frame with the columns "tumorCell" and the cumulative duration and number of contacts.
#' @export
#'
#' @examples

analyze_contacts <- function( contactList, secPerFrame = Inf){
  
  contacts_df <- bind_rows(contactList, .id = "column_label")
  
  contacts_tumorCell <- split( contacts_df, contacts_df$tumorCell )
  
  length( contacts_tumorCell )
  
  # Compute cumulative contact time per tumor cell
  
  duration_in_frames <- unname( unlist( lapply( contacts_tumorCell, function(x){
    return( sum (x$duration))
  } ) ))
  
  duration_in_min <- duration_in_frames * secPerFrame/60
  
  lengths <- unlist( unname( lapply( contacts_tumorCell, nrow) ) )
  
  
  contacts_tumorCell_duration <- data.frame(
    tumorCell = names( contacts_tumorCell ),
    cum_duration_in_frames =  duration_in_frames,
    cum_duration_in_min = duration_in_min,
    num_contacts = lengths
  )
  
  contacts_tumorCell_duration$duration_in_min <- lapply( contacts_tumorCell_duration$duration_in_min, round, digits = 3)
  
  return( contacts_tumorCell_duration )
}