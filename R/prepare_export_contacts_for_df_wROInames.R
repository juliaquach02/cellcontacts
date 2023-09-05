

#' Prepare computed contacts for export as .csv file
#'
#' @param pairs     Cell pairs in contact
#' @param tracksTxt Tracks file with Track ID, frame number, xy-position
#' @param cellType  Celltype can either by "tumourCell" or "Tcell" (use this parameter to add it as variable in the exported df)
#'
#' @return
#' @export
#'
#' @examples
prepare_export_contacts_for_df_wROInames <- function( pairs, tracksTxt, cellType = "tumourCell" ){
  
  # Get names of (tumour or T) cells that were in contact
  cellsContact <- vector( "list", length = nrow(pairs) )
  
  if( cellType == "tumourCell"){
    
    for( i in 1:length( pairs$tumourCell ) ){
      cellsContact[[i]] <- as.list(strsplit( pairs$tumourCell[[i]], ",")[[1]]) %>% 
        as.character() %>% 
        gsub("-", ".", .)
    }
  } else if ( cellType == "TCell" ){
    
    for( i in 1:length( pairs$Tcell ) ){
      cellsContact[[i]] <- as.list(strsplit( pairs$Tcell[[i]], ",")[[1]]) %>% 
        as.character() %>% 
        gsub("-", ".", .)
    }
    
  }
  
  cellsContact <- unlist( cellsContact )
  
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

