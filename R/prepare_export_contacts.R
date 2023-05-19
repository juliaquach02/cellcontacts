
#' Creating data frame with tumor _or_ T cells in contact
#'
#' @param pairs List of computed cell pairs that were in contact 
#' with column "Var1" for tumor cells and "Var2" for T cells.
#' @param tracksTxt Data frame of exported tracks. Usually, 
#' the data was previously exported from TrackMate or Imaris and loaded as table from a .csv file.
#' @param cellType Either "tumorCell" or "TCell"
#'
#' @return The data frame of exported tracks reduced to only the rows that represent
#' cell ROIs that were involved in a contact.
#' @export
#'
#' @examples
prepare_export_contacts <- function( pairs, tracksTxt, cellType = "tumorCell" ){
  
  # Get names of (tumor or T) cells that were in contact
  cellsContact <- vector( "list", length = length(pairs) )

  if( cellType == "tumorCell"){
    
    for( i in 1: length( cellsContact )){
      cellsContact[[i]] <- pairs[[i]]$Var1
    }
  } else if ( cellType == "TCell" ){

    for( i in 1: length( cellsContact )){
      cellsContact[[i]] <- pairs[[i]]$Var2
    }
  }

  # Edit their names
  cellsContact <- as.character( unlist( cellsContact ) )
  cellsContact <-  gsub("-", ".", cellsContact)
  
  # Get indices of those names in the exported txt-file
  indices_cell_in_contact <- vector( "list", length = length( cellsContact ) )
  
  for( i in 1:length( cellsContact )){
    indices_cell_in_contact[[i]] <- which( tracksTxt$Label == cellsContact[[i]])
  }
  
  indices_cell_in_contact <- unlist( indices_cell_in_contact )
  
  # Select only cells in contact from txt-file
  tracksTxt_inContact <- tracksTxt[ indices_cell_in_contact,]

  return( tracksTxt_inContact )  
  
}