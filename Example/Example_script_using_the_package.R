
# This is an example script how to use the cellcontacts package on live cell imaging data.

library( cellcontacts )

# Setting directories ----------------------------------------------------------

# Source directory to ROIs 
tumorROIsPath <- paste0(getwd(), "/Example/Tumour_Cells/RoiSet_Tumour_Cells/")
tcellROIsPath <- paste0(getwd(), "/Example/T_Cells//RoiSet_T_Cells/")
endPointROIPath <- paste0(getwd(),"/Example/Endpoint_Measurement/RoiSet_Endpoint_DAPI.zip")

# Source directory to tracks and track information
tumorTracksPath <-  paste0(getwd(),"/Example/Tumour_Cells/Tracks_Tumour_Cells.csv")
tcellTracksPath <-  paste0(getwd(), "/Example/T_Cells/Tracks_T_Cells.csv")

# Source directory to endpoint measurement of signal intensity
endPointMeasPath <- paste0(getwd(), "/Example/Endpoint_Measurement/Results_Endpoint_Intensity_p21.csv")

# Destination directory for plots and exported data frames
resultsPath <- paste0(getwd(), "/Example/Results/")

# Importing tracks ----------------------------------------------------

# Load track information as txt

tumorTracksTxt <- read.table( tumorTracksPath, header = TRUE, sep = ",", )
tcellTracksTxt <- read.table( tcellTracksPath, header = TRUE, sep = ",",)

# Load endpoint data ----------------------------------------------------

endPointROIs <- read.ijzip( endPointROIPath )
endPointMeasTxt <- read.table( endPointMeasPath, header = TRUE, sep = ",", )

# Load tumour ROIs of movie -----------------------------------------------------------

# Load function

read_ijzip <- function( zipPath ){
  
  print( zipPath )
  result <- read.ijzip(zipPath)
  return( result )
  
}

# Create list of zipped ROI folders
numSubfolders <- 14 # Adjust numSubfolders for each data set
pathROIs <- list()

for( i in 1:numSubfolders){
  pathROIs[[i]] <- paste0(tumorROIsPath, as.character(i-1), ".zip")
}

# Subdivide list into two lists to create two jobs
pathROIsPt1 <- pathROIs[ 1:floor(numSubfolders/2) ]
pathROIsPt2 <- pathROIs[ (floor(numSubfolders/2) + 1):numSubfolders ]

startTime <- Sys.time()
print( startTime)

# Load ROIs in parallel
plan(multisession)

# job 1
ROIsPt1 %<-% {
  ROIsPt1 <- lapply( pathROIsPt1, read_ijzip)
}

# job 2
ROIsPt2 %<-%{
  ROIsPt2 <- lapply( pathROIsPt2, read_ijzip)
}

tumorROIs <- append( ROIsPt1, ROIsPt2)

endTime <- Sys.time()
print( endTime )
endTime - startTime
rm(ROIsPt1, ROIsPt2) # Clear memory

# Load T cell ROIs of movie -----------------------------------------------------------

# Create list of zipped ROI folders
numSubfolders <- 2 #### Set numSubfolders for each data set
pathROIs <- list()

for( i in 1:numSubfolders){
  pathROIs[[i]] <- paste0(tcellROIsPath, as.character(i-1), ".zip")
}

# Subdivide list into two lists to create two jobs
pathROIsPt1 <- pathROIs[ 1:floor(numSubfolders/2) ]
pathROIsPt2 <- pathROIs[ (floor(numSubfolders/2) + 1):numSubfolders ]

startTime <- Sys.time()
print( startTime)

# Load ROIs in parallel

plan(multisession)

# job 1
ROIsPt1 %<-% {
  ROIsPt1 <- lapply( pathROIsPt1, read_ijzip)
}

# job 2
ROIsPt2  %<-% {
  ROIsPt2 <- lapply( pathROIsPt2, read_ijzip)
}

tcellROIs <- append(ROIsPt1, ROIsPt2)

endTime <- Sys.time()
print( endTime )
endTime - startTime

rm(ROIsPt1, ROIsPt2) # Clear memory

# Match track names to frame number --------------------------------------------

tumor_trackName_frameNum <- matchTrackNamesWithFrameNum( tumorTracksTxt )
tcell_trackName_frameNum <- matchTrackNamesWithFrameNum( tcellTracksTxt )

print( head( tumor_trackName_frameNum ))
print( head( tcell_trackName_frameNum ))




# Insert ROIs into hash map  ---------------------------------------------------

# Hash map names to coordinates

tumorROImap <- hashmap( default = "No value for this key")
invisible( lapply( tumorROIs, insert_Hashmap_NamesToCoords, ROImap = tumorROImap) )

tcellROImap <- hashmap( default = "No value for this key")
invisible(  lapply( tcellROIs, insert_Hashmap_NamesToCoords, ROImap = tcellROImap)  )

# Hash map time points to names

insert_Hashmap_FrameNumToNames( tumor_trackName_frameNum, ROImap = tumorROImap )
insert_Hashmap_FrameNumToNames( tcell_trackName_frameNum, ROImap = tcellROImap )

# Add last time point to both hash maps

lastTimepoint <- max( as.integer( tumor_trackName_frameNum$Frame ), as.integer( tcell_trackName_frameNum$Frame ) )

tumorROImap[["lastTimepoint"]] <- lastTimepoint
tcellROImap[["lastTimepoint"]] <- lastTimepoint

# Hash map names to center points

tumorROImap_center <- hashmap( default = "No value for this key")
tcellROImap_center <- hashmap( default = "No value for this key")

invisible( lapply( tumorROIs, insert_Hashmap_NamesToCenter, ROImap = tumorROImap_center ) )
invisible( lapply( tcellROIs, insert_Hashmap_NamesToCenter, ROImap = tcellROImap_center ) )

# Hash map names to field in grid of respective ROI center point

grid <- create_grid( c(0,600), c(0,600), dim = 6) ### Frame dimensions should be checked for each data set

tumorROImap_NamesToGrid <- hashmap( default = "No value for this key")
tcellROImap_NamesToGrid <- hashmap( default = "No value for this key")

invisible( lapply( tumorROIs, insert_Hashmap_NamesToGrid, ROImap = tumorROImap_NamesToGrid, grid = grid ) )
invisible( lapply( tcellROIs, insert_Hashmap_NamesToGrid, ROImap = tcellROImap_NamesToGrid, grid = grid ) )

# Put endPointROIs into field and hashmap

endpointROImap <- hashmap( default = "No value for this key")
insert_Hashmap_NamesToCoords( endPointROIs, endpointROImap)
insert_Hashmap_NamesToGrid( endPointROIs, ROImap = tumorROImap_NamesToGrid, grid = grid  )


# Delete loaded zip folders to clear memory -------------------------------

rm( tumorROIs )
rm( tcellROIs )
gc()

# Map tumor tracks from movie to endpoint staining ----------------------------

matches <- match_to_endpoint_ROIs(  endPointROIs, endpointROImap, tumorROImap, tumorROImap_center, tumorROImap_NamesToGrid )

# Plotting matches

numColours <- 10
plotMatches( matches, tumorROImap, endpointROImap,
             cols = brewer.pal( numColours,'Spectral'), # Set colors of cells
             xlim = c(0,550), ylim = c(0,550) ) # Set dimensions of the frame

# Add measurement results to matches

result <- add_meas_to_matches( matches, endPointMeasTxt )

# Compute contacts --------------------------------------------------------

startTime <- Sys.time()
print( startTime)

cellDist <- lapply( 0: tumorROImap[["lastTimepoint"]], compute_distTimepoint_wGrid,
                    gridWidth = 100,
                    ROImap1 = tumorROImap,
                    ROImap2 = tcellROImap,
                    ROImapField1 = tumorROImap_NamesToGrid,
                    ROImapField2 = tcellROImap_NamesToGrid )


endTime <- Sys.time()
print( endTime )
endTime - startTime

minDuration <- 4

pairs <- cellDist %>% 
  add_columnPair() %>% # Add column pair
  lapply( add_columnTimepoint, tumor_trackName_frameNum = tumor_trackName_frameNum) %>% # Add column time point
  lapply( check_contacts, distThresh = 7) %>% # Evaluate whether the distance is below threshold
  lapply( keep_contactTrue)  %>% # Keep only pairs with distance below threshold
  Filter(Negate(is.null), .) %>% # Discard empty list entries
  .[lapply( ., nrow) > 0]  %>% 
  lapply( as.data.frame ) %>%  
  bind_rows() %>%  
  split( ., .$pair) %>%  # Split by pair
  .[ lapply( ., nrow) > minDuration] # Get all pairs above minimum duration


# Export computed contacts as .csv ----------------------------------------

tumorTracksTxt_inContact <- prepareExportContacts( pairs, tumorTracksTxt, cellType = "tumorCell")
tcellTracksTxt_contact <- prepareExportContacts( pairs, tcellTracksTxt, cellType = "TCell")

# Export as .csv
write.csv( tumorTracksTxt_inContact, paste0(exportCSVPath, "Tracks_Tumour_Cells_in_contatact.csv"), row.names=FALSE)
write.csv( tcellTracksTxt_contact, paste0(exportCSVPath, "Tracks_T_Cells_in_contact.csv"), row.names=FALSE)

