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

The goal of this R package is to enable the quantitative analysis of T
cell-tumor cell interaction in live cell imaging films.

------------------------------------------------------------------------

# **Installation**

The latest development version of cellcontacts can be installed from
GitHub:

    devtools::install_github( "juliaquach02/cellcontacts" )

The package can be loaded via:

    library( cellcontacts )

------------------------------------------------------------------------

# **Example**

The package was built to analyze 2D live-cell imaging movies. Before
using the package, the cells need to segmented and tracked, for example
using the Fiji plugin [TrackMate](https://imagej.net/plugins/trackmate/)
by Tinevez at al (Tinevez et al. 2017).

The cellcontacts package processes

-   ROIs representing segmented cells, which are saved as .roi-files in
    a zipped folder, and
-   cell tracks, which are saved as .csv file with the columns “Label”,
    “X”, “Y”, “Frame”.

## **Prior analysis**

TrackMate is a modular tool that enables the segmentation and tracking
of cells via common segmentation tools,
e.g. [StarDist](https://imagej.net/plugins/stardist), and tracking
tools, e.g. the [LAP tracker]().

This package requires separate segmentation and tracking of tumor and T
cells. After segmentation and tracking, ROIs should be renamed in the
TrackMate GUI by their spot name with incremented index. Afterwards,
they can be exported to the ROI manager, from where they can be saved as
zipped folder.In addition, cell tracks should be saved from the
TrackMate GUI as .csv file.

ADD SCREENSHOTS

## **Setting directories and loading the data**

Before starting the analysis, source directories need to be set.

Also, destination directories need to be set.

To load tracks from a .csv-file, we simply use the `read.table()`
function. To load the cell ROIs, we use the `read.ijzip()` function from
the
[RImageJROI](https://cran.r-project.org/web/packages/RImageJROI/index.html)
package. As the number of ROIs can be very large, we might need to split
the zipped ROIs into multiple zipped subfolders and load the folders in
parallel using the
[future](https://cran.r-project.org/web/packages/future/index.html)
package. To save the ROIs into separate subfolders, an ImageJ macro is
available [here]().

## **Analysis**

We follow multiple steps to compute cell-cell distances and to filter
for cell-cell contacts.

### 1. Matching track names to their frame number

### 2. Putting data into hash maps

### 3. Computing cell-cell distances

### 4. Filtering for cell-cell contacts

### 5. Export the results for visualization and validation

------------------------------------------------------------------------

# **References**

Tinevez, Jean-Yves, Nick Perry, Johannes Schindelin, Genevieve M.
Hoopes, Gregory D. Reynolds, Emmanuel Laplantine, Sebastian Y. Bednarek,
Spencer L. Shorte, and Kevin W. Eliceiri. 2017. “TrackMate: An Open and
Extensible Platform for Single-Particle Tracking.” Journal Article.
*Methods* 115: 80–90.
https://doi.org/<https://doi.org/10.1016/j.ymeth.2016.09.016>.
