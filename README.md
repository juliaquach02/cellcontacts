------------------------------------------------------------------------

# **About**

------------------------------------------------------------------------

This R package was written to process imaging files acquired from live
cell imaging of T cells and tumor cells. It requires the prior analysis
of the live cell imaging films with a cell tracking tool, e.g.,
[TrackMate](https://imagej.net/plugins/trackmate/) or
[Imaris](https://imaris.oxinst.com/products/imaris-for-tracking). It
offers functions to compute cell-cell distances, cell-cell contacts, and
characteristics of cell-cell interaction. Moreover, it allows to connect
the results to immunological staining results.

------------------------------------------------------------------------

# **Goal of the project**

------------------------------------------------------------------------

The goal of this R package is to enable the quantitative analysis of T
cell-tumor cell interaction in live cell imaging films.

------------------------------------------------------------------------

# **Installation**

------------------------------------------------------------------------

The latest development version of cellcontacts can be installed from
GitHub:

    devtools::install_github( "juliaquach02/cellcontacts" )

The package can be loaded via:

    library( cellcontacts )

------------------------------------------------------------------------

# **Work flow**

------------------------------------------------------------------------

The package was built to analyze 2D live-cell imaging movies. Before
using the package, the cells need to segmented and tracked, for example
using the Fiji plugin [TrackMate](https://imagej.net/plugins/trackmate/)
by Tinevez at al (Tinevez et al. 2017).

The cellcontacts package processes

-   ROIs representing segmented cells, which are saved as .roi-files in
    a zipped folder, and
-   cell tracks, which are saved as .csv file with the columns “Label”,
    “X”, “Y”, “Frame”.

### **Preprocessing**

For the segmentation and tracking of the cells in the live-cell imaging
film, TrackMate proves to be a useful tool. It is a modular tool that
enables the segmentation and tracking of cells via common segmentation
tools, e.g. [StarDist](https://imagej.net/plugins/stardist), and
tracking tools, e.g. the [LAP
tracker](https://www.nature.com/articles/nmeth.1237).

The cellcontacts package requires the segmentation and tracking of tumor
and T cells as two separate cell populations. Cell areas, called cell
ROIs (region of interest), should be named by their track name with
index in the format \*Track\_\[id\]\_\[index\]\* and saved as .roi-files
in a zipped folder. In addition, cell tracks should be saved as .csv
file.

To ensure correct import of the data in RStudio, please make sure that
file names do not contain a “.” and that only the first line of the .csv
file contain column headers.

### **Setting directories and loading the data**

After setting source and destination directories, we can load the data
into RStudio. To import the cell tracks, we simply use the
`read.table()` function. To import the cell ROIs, we use the
`read.ijzip()` function from the
[RImageJROI](https://cran.r-project.org/web/packages/RImageJROI/index.html)
package.

As the number of ROIs might be very large, it might be necessary to
split the zipped ROIs into multiple zipped subfolders and load the
folders in parallel using the
[future](https://cran.r-project.org/web/packages/future/index.html)
package. To save the ROIs into separate subfolders, an ImageJ macro is
provided
[here](ImageJ_Macros/Macro_Rename_and_Save_ROIs_in_Subfolders.ijm).

Below, the code to load the tumour cell tracks and tumour cell ROIs is
displayed. Analogously, we can load the T cell tracks and T cell ROIs.

    # Importing tracks
    tumorTracksTxt <- read.table( tumorTracksPath, header = TRUE, sep = ",", )

    # Load tumour ROIs of movie
    # Create list of zipped ROI folders (Adjust numSubfolders for each data set)
    numSubfolders <- 14 
    pathROIs <- list()

    for( i in 1:numSubfolders){
      pathROIs[[i]] <- paste0(tumorROIsPath, as.character(i-1), ".zip")
    }

    # Subdivide list into two lists to create two jobs
    pathROIsPt1 <- pathROIs[ 1:floor(numSubfolders/2) ]
    pathROIsPt2 <- pathROIs[ (floor(numSubfolders/2) + 1):numSubfolders ]

    # Load ROIs in parallel
    plan(multisession)

    ROIsPt1 %<-% {  # job 1
      ROIsPt1 <- lapply( pathROIsPt1, read.ijzip)
    }
    ROIsPt2 %<-%{ # job 2
      ROIsPt2 <- lapply( pathROIsPt2, read.ijzip) 
    }

    tumorROIs <- append( ROIsPt1, ROIsPt2)

### **Analysis**

To process a large set of segmented cells, we need to put the data into
a suitable data structure to allow easy and efficient computation and
access.

### 1. Matching track names to their frame number

Using the function `matchTrackNamesWithFrameNum()`, we assign the cell
ROIs to their corresponding frame number.

    tumor_trackName_frameNum <- matchTrackNamesWithFrameNum( tumorTracksTxt )
    tcell_trackName_frameNum <- matchTrackNamesWithFrameNum( tcellTracksTxt )

    print( head( tumor_trackName_frameNum ))

    ##     TrackName Frame
    ## 1 Track_0-117   116
    ## 2 Track_0-125   124
    ## 3  Track_0-21    20
    ## 4 Track_0-153   152
    ## 5  Track_0-51    50
    ## 6 Track_0-148   147

    print( head( tcell_trackName_frameNum ))

    ##    TrackName Frame
    ## 1 Track_0-62    61
    ## 2 Track_0-96    95
    ## 3 Track_0-45    44
    ## 4 Track_0-28    27
    ## 5 Track_0-88    87
    ## 6  Track_0-4     3

### 2. Putting data into hash maps

To efficiently access our data during computation, we arrange our data
set into hash maps. Furthermore, we sort the cell ROIs into a 2D grid
with a column and row width of 100 µm to get rough estimates of their
position.

To create a 2D grid, we provide the function `create_grid()`. To put the
data into hash maps, we provide the functions

-   `insert_Hashmap_FrameNumToNames()` to retrieve track names of all
    cells for a specific time point.
-   `insert_Hashmap_NamesToCenter()` to retrieve the center point for a
    specific ROI name.
-   `insert_Hashmap_NamesToGrid()` to retrieve a rough position in the
    frame for a specific ROI name.
-   `insert_Hashmap_NamesToCoords()` to retrieve the ROI coordinates for
    a specific ROI name

<!-- -->

    # Hash map from names to coordinates
    tumorROImap <- hashmap( default = "No value for this key")
    invisible( lapply( tumorROIs, insert_Hashmap_NamesToCoords, ROImap = tumorROImap) )

    tcellROImap <- hashmap( default = "No value for this key")
    invisible(  lapply( tcellROIs, insert_Hashmap_NamesToCoords, ROImap = tcellROImap)  )

    # Hash map from time points to names
    insert_Hashmap_FrameNumToNames( tumor_trackName_frameNum, ROImap = tumorROImap )
    insert_Hashmap_FrameNumToNames( tcell_trackName_frameNum, ROImap = tcellROImap )

    # Hash map from names to center points
    tumorROImap_center <- hashmap( default = "No value for this key")
    tcellROImap_center <- hashmap( default = "No value for this key")

    invisible( lapply( tumorROIs, insert_Hashmap_NamesToCenter, ROImap = tumorROImap_center ) )
    invisible( lapply( tcellROIs, insert_Hashmap_NamesToCenter, ROImap = tcellROImap_center ) )

    # Hash map from names to position in grid
    grid <- create_grid( c(0,600), c(0,600), dim = 6) ### Frame dimensions should be checked for each data set

    tumorROImap_NamesToGrid <- hashmap( default = "No value for this key")
    tcellROImap_NamesToGrid <- hashmap( default = "No value for this key")

    invisible( lapply( tumorROIs, insert_Hashmap_NamesToGrid, ROImap = tumorROImap_NamesToGrid, grid = grid ) )
    invisible( lapply( tcellROIs, insert_Hashmap_NamesToGrid, ROImap = tcellROImap_NamesToGrid, grid = grid ) )

    # Add endPointROIs into field and hash map
    endpointROImap <- hashmap( default = "No value for this key")
    insert_Hashmap_NamesToCoords( endPointROIs, endpointROImap)
    insert_Hashmap_NamesToGrid( endPointROIs, ROImap = tumorROImap_NamesToGrid, grid = grid  )

### 3. Mapping tracks to endpoint staining

We often want to connect the dynamic information of the cell tracks to
the static information of the same cells from immunological staining.
For this, we provide the function `match_to_endpoint_ROIs()` to match
the cell tracks to the corresponding cell ROIs at the end point. The
function `add_meas_to_matches()` can add the measurements of the signal
intensity to the mapping of cell tracks to endpoint ROIs.

    # Map tumor tracks from movie to endpoint staining
    matches <- match_to_endpoint_ROIs(  endPointROIs, endpointROImap, tumorROImap, tumorROImap_center, tumorROImap_NamesToGrid )

    # Add measurement results to matches
    result <- add_meas_to_matches( matches, endPointMeasTxt )
    print( head( result ) )

    ##   endpoint_cell  movies_cell Area      Mean   Min   Max
    ## 2             2 Track_10-155  544 24376.570  4375 63320
    ## 3             3  Track_5-155  451 14991.359  5364 21044
    ## 4             4  Track_1-155  593  7780.622  3233 10774
    ## 5             5  Track_2-155  347  8440.568  4352 11136
    ## 6             6 Track_178-23  190 29328.805 10126 57951
    ## 7             7 Track_71-155  242 11620.851  6800 15060

To check the mapping, we can plot the matched endpoint ROIs and cell
tracks by their color in one plot:

<center>
<img src="Plot_Matched_ROIs.jpg" id="id" class="class"
style="width:56.0%;height:51.2%" alt="Matched_ROIs" />*Cell areas at
last time point are mapped to the cell areas from the immunological
staining at the endpoint. Matched cells are plotted in the same color.*
</center>

### 4. Computing cell-cell distances

Cell-cell distances need to be computed to filter for cell-cell
contacts. For this, we provide the function
`compute_distTimepoint_wGrid()`.

This function computes for a given time point all possible tumour cell/T
cell pairs. For each pair, the function checks the rough position of
both cells using their position in the 2D grid. If the cells are at
least in neighboring columns and rows of the grid, the euclidean
distance between the cell ROI is computed.

The output of the function is a data frame which lists all possible cell
pairs and either the distance of the pair or a remark that the distance
is substantially larger than the distance threshold for a cell-cell
contact.

    cellDist <- lapply( 0: tumorROImap[["lastTimepoint"]], compute_distTimepoint_wGrid,
                                  gridWidth = 100,
                                  ROImap1 = tumorROImap,
                                  ROImap2 = tcellROImap,
                                  ROImapField1 = tumorROImap_NamesToGrid,
                                  ROImapField2 = tcellROImap_NamesToGrid )

    print( head(cellDist[[1]]) )

    ##        Var1      Var2 distances
    ## 1 Track_0-1 Track_0-1     >>100
    ## 2 Track_1-1 Track_0-1     >>100
    ## 3 Track_2-1 Track_0-1     >>100
    ## 4 Track_3-1 Track_0-1     >>100
    ## 5 Track_4-1 Track_0-1     >>100
    ## 6 Track_5-1 Track_0-1     >>100

### 5. Filtering for cell-cell contacts

To filter the cell pairs for cell-cell contacts, we only keep cell pairs
that maintain a distance below a distance threshold for a minimum
duration of frames. The distance and duration threshold can be set
manually.

As result, we obtain a list of tumor cell/T cell pairs and each list
entry represents one pair and contains the columns “time point” and
“distances”.

    # Set a threshold for the minimum duration of a contact
    minDuration <- 4

    # To filter for cell-cell contacts, we use pipes from the tidyverse package.
    pairs <- cellDist %>% 
        add_columnPair() %>% 
        lapply( add_columnTimepoint, tumor_trackName_frameNum = tumor_trackName_frameNum) %>% #
        lapply( check_contacts, distThresh = 7) %>% #
        lapply( keep_contactTrue)  %>% 
        Filter( Negate(is.null), .) %>% 
        .[ lapply( ., nrow) > 0 ]  %>% 
        lapply( as.data.frame ) %>%  
        bind_rows() %>%  
        split( ., .$pair ) %>%  
        .[ lapply( ., nrow) > minDuration ] 

    print( head( pairs[[1]] ) )

    ##           Var1       Var2        distances              pair timePoint contact
    ## 10  Track_10-1 Track_15-1 4.24264068711928 Track_10-Track_15         0    TRUE
    ## 33  Track_10-2 Track_15-2                0 Track_10-Track_15         1    TRUE
    ## 57  Track_10-3 Track_15-3                0 Track_10-Track_15         2    TRUE
    ## 83  Track_10-4 Track_15-4                0 Track_10-Track_15         3    TRUE
    ## 108 Track_10-5 Track_15-5 4.24264068711928 Track_10-Track_15         4    TRUE
    ## 128 Track_10-6 Track_15-6 2.82842712474619 Track_10-Track_15         5    TRUE

### 6. Validation and export of results

To check of the computed cell-cell contacts, we export the track
information of the T cells that were in contact as .csv-file using
`prepareExportContacts()` and `write.csv()`.

    # Export computed contacts as .csv 
    tcellTracksTxt_contact <- prepareExportContacts( pairs, tcellTracksTxt, cellType = "TCell")
    write.csv( tcellTracksTxt_contact, paste0(resultsPath, "Tracks_T_Cells_in_contact.csv"), row.names=FALSE)

    # Export computed contacts as .csv -
    tumorTracksTxt_inContact <- prepareExportContacts( pairs, tumorTracksTxt, cellType = "tumorCell")
    write.csv( tumorTracksTxt_inContact, paste0(resultsPath, "Tracks_Tumour_Cells_in_contatact.csv"), row.names=FALSE)

The exported files are loaded into TrackMate via ImageJ &gt; Plugins
&gt; Tracking &gt; TrackMate CSV Importer. Using the .csv file,
TrackMate labels the T cells in the .tif-file only *during* a contact.

This allows us to revisit the live-cell imaging film and to check
whether cell-cell contacts are correctly computed.

<center>
<img src="Screenshot_TrackMate_CSV_Importer.JPG" id="id" class="class"
style="width:80.0%;height:80.0%" alt="TrackMate_CSV_Importer" />  
*Via the TrackMate CSV Importer GUI, we can load our results back into a
TrackMate session. For this, we choose the image and the .csv file. For
the .csv file, we add information on the content of its columns.*
</center>

------------------------------------------------------------------------

# **Data**

------------------------------------------------------------------------

The example folder contains the following files:

-   Segmented cell ROIs for tumor and T cells in multiple zipped folders
-   Cell tracks for tumor and T cells as .csv files
-   The TrackMate sessions for tumor cells and T cells saved as .xml
    files
-   Results of an immunological staining image of the tumor cells and T
    cells at the endpoint of the live-cell imaging film with a DAPI,
    phalloidin and p21 channel as .csv file.
-   The R script to run the above mentioned analyses.

For more questions and remarks, feel free to open an issue on GitHub.

------------------------------------------------------------------------

# **References**

------------------------------------------------------------------------

Tinevez, Jean-Yves, Nick Perry, Johannes Schindelin, Genevieve M.
Hoopes, Gregory D. Reynolds, Emmanuel Laplantine, Sebastian Y. Bednarek,
Spencer L. Shorte, and Kevin W. Eliceiri. 2017. “TrackMate: An Open and
Extensible Platform for Single-Particle Tracking.” Journal Article.
*Methods* 115: 80–90.
https://doi.org/<https://doi.org/10.1016/j.ymeth.2016.09.016>.
