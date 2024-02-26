NFSC-CPR
================

This R package facilitates access and analysis of
[NFSC](https://www.fisheries.noaa.gov/about/northeast-fisheries-science-center)
[Continuous Plankton
Recorder](https://en.wikipedia.org/wiki/Continuous_Plankton_Recorder)
(CPR) data. Data can imported from distrubuted
[Excel](https://en.wikipedia.org/wiki/Microsoft_Excel) spreadsheets into
data frames, [tibbles](https://tibble.tidyverse.org/) or [sf
tables](https://r-spatial.github.io/sf/).

> This dataset was obtained from [NOAA’s
> NFSC](https://www.fisheries.noaa.gov/about/northeast-fisheries-science-center)
> on 20 January 2024 and might not represent the most up to date data.
> Please contact NOAA directly for the most recent data.

## Requirements

- [R v4.1+](https://www.r-project.org/)
- [rlang](https://CRAN.R-project.org/package=rlang)
- [dplyr](https://CRAN.R-project.org/package=dplyr)
- [readxl](https://CRAN.R-project.org/package=readxl)
- [readr](https://CRAN.R-project.org/package=readr)

## Installation

    remotes::install_github("BigelowLab/nfsccrp")

## Usage

### Read the data

The dataset contains both zooplankton and phytoplankton data from the
Mid-Atlantic Bight. We should access to the zooplankton data, but it is
easy to switch to phytoplankton. We can read the data in its “raw” state
(a wide table), pivoted into long form or as an sf object.

#### Read as a wide table

``` r
library(nfsccpr)
x = read_cpr(name = "zooplankton", long = FALSE, form = "table")
x
```

    ## # A tibble: 4,459 × 628
    ##    Cruise Station  Year Month   Day  Hour Minute `Latitude (degrees)`
    ##    <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>                <dbl>
    ##  1 EG7107      43  1971    11    15    17      0                 39.6
    ##  2 EG7107      45  1971    11    15    17      0                 39.5
    ##  3 EG7108      25  1971    12    15     5      0                 39.3
    ##  4 EG7108      27  1971    12    15     5      0                 39.2
    ##  5 EG7108      29  1971    12    15     5      0                 39.0
    ##  6 EG7108      31  1971    12    15    17      0                 38.8
    ##  7 AL7206      11  1972     8    19    21     23                 39.3
    ##  8 AL7206      13  1972     8    19    19     44                 39.0
    ##  9 AL7206      15  1972     8    19    18      5                 38.6
    ## 10 AL7206      19  1972     8    19    14     17                 38.0
    ## # ℹ 4,449 more rows
    ## # ℹ 620 more variables: `Longitude (degrees)` <dbl>,
    ## #   `Phytoplankton Color Index` <dbl>,
    ## #   `Unidentified plankton and fragments [unstaged] [2.999]` <dbl>,
    ## #   `Copepoda [nauplius] [100.13]` <dbl>,
    ## #   `Copepoda [copepodite V] [100.24]` <dbl>,
    ## #   `Copepoda [PARVA (POSTLARVA)] [100.37]` <dbl>, …

#### Read as a long table

``` r
x = read_cpr(name = "zooplankton", long = TRUE, form = "table")
x
```

    ## # A tibble: 2,755,662 × 12
    ##    Cruise Station  Year Month   Day  Hour Minute `Latitude (degrees)`
    ##    <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>                <dbl>
    ##  1 EG7107      43  1971    11    15    17      0                 39.6
    ##  2 EG7107      43  1971    11    15    17      0                 39.6
    ##  3 EG7107      43  1971    11    15    17      0                 39.6
    ##  4 EG7107      43  1971    11    15    17      0                 39.6
    ##  5 EG7107      43  1971    11    15    17      0                 39.6
    ##  6 EG7107      43  1971    11    15    17      0                 39.6
    ##  7 EG7107      43  1971    11    15    17      0                 39.6
    ##  8 EG7107      43  1971    11    15    17      0                 39.6
    ##  9 EG7107      43  1971    11    15    17      0                 39.6
    ## 10 EG7107      43  1971    11    15    17      0                 39.6
    ## # ℹ 2,755,652 more rows
    ## # ℹ 4 more variables: `Longitude (degrees)` <dbl>,
    ## #   `Phytoplankton Color Index` <dbl>, name <chr>, abundance <dbl>

#### Read as a long table cast to sf

``` r
x = read_cpr(name = "zooplankton", long = TRUE, form = "sf")
x
```

    ## Simple feature collection with 2755662 features and 10 fields
    ## Geometry type: POINT
    ## Dimension:     XY
    ## Bounding box:  xmin: 69.01825 ymin: 36.66752 xmax: 73.8683 ymax: 40.4249
    ## Geodetic CRS:  WGS 84
    ## # A tibble: 2,755,662 × 11
    ##    Cruise Station  Year Month   Day  Hour Minute Phytoplankton Color Ind…¹ name 
    ##  * <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>                     <dbl> <chr>
    ##  1 EG7107      43  1971    11    15    17      0                         1 Unid…
    ##  2 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  3 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  4 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  5 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  6 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  7 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  8 EG7107      43  1971    11    15    17      0                         1 Cope…
    ##  9 EG7107      43  1971    11    15    17      0                         1 Cope…
    ## 10 EG7107      43  1971    11    15    17      0                         1 Cope…
    ## # ℹ 2,755,652 more rows
    ## # ℹ abbreviated name: ¹​`Phytoplankton Color Index`
    ## # ℹ 2 more variables: abundance <dbl>, geometry <POINT [°]>

### Import a raw data file

The data were shared as a large two-sheet Excel document. It’s difficult
to know if the format of the raw data file will remain as that
distributed in January 2024. Importing the one we were provided is
encoded in a package function. The package can be adapted for other
formats but may require a small effort in adapting the code.

``` r
ff = "/Users/ben/Library/CloudStorage/Dropbox/data/noaa/nmfs/cpr/MAB CPR (Jan 20, 2024 update).xlsx"
x = import_cpr(ff[1])
x
```

    ## $Zooplankton
    ## # A tibble: 4,459 × 628
    ##    Cruise Station  Year Month   Day  Hour Minute `Latitude (degrees)`
    ##    <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>                <dbl>
    ##  1 EG7107      43  1971    11    15    17      0                 39.6
    ##  2 EG7107      45  1971    11    15    17      0                 39.5
    ##  3 EG7108      25  1971    12    15     5      0                 39.3
    ##  4 EG7108      27  1971    12    15     5      0                 39.2
    ##  5 EG7108      29  1971    12    15     5      0                 39.0
    ##  6 EG7108      31  1971    12    15    17      0                 38.8
    ##  7 AL7206      11  1972     8    19    21     23                 39.3
    ##  8 AL7206      13  1972     8    19    19     44                 39.0
    ##  9 AL7206      15  1972     8    19    18      5                 38.6
    ## 10 AL7206      19  1972     8    19    14     17                 38.0
    ## # ℹ 4,449 more rows
    ## # ℹ 620 more variables: `Longitude (degrees)` <dbl>,
    ## #   `Phytoplankton Color Index` <dbl>,
    ## #   `Unidentified plankton and fragments [unstaged] [2.999]` <dbl>,
    ## #   `Copepoda [nauplius] [100.13]` <dbl>,
    ## #   `Copepoda [copepodite V] [100.24]` <dbl>,
    ## #   `Copepoda [PARVA (POSTLARVA)] [100.37]` <dbl>, …
    ## 
    ## $Phytoplankton
    ## # A tibble: 4,459 × 186
    ##    Cruise Station  Year Month   Day  Hour Minute `Latitude (degrees)`
    ##    <chr>    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>                <dbl>
    ##  1 EG7107      43  1971    11    15    17      0                 39.6
    ##  2 EG7107      45  1971    11    15    17      0                 39.5
    ##  3 EG7108      25  1971    12    15     5      0                 39.3
    ##  4 EG7108      27  1971    12    15     5      0                 39.2
    ##  5 EG7108      29  1971    12    15     5      0                 39.0
    ##  6 EG7108      31  1971    12    15    17      0                 38.8
    ##  7 AL7206      11  1972     8    19    21     23                 39.3
    ##  8 AL7206      13  1972     8    19    19     44                 39.0
    ##  9 AL7206      15  1972     8    19    18      5                 38.6
    ## 10 AL7206      19  1972     8    19    14     17                 38.0
    ## # ℹ 4,449 more rows
    ## # ℹ 178 more variables: `Longitude (degrees)` <dbl>,
    ## #   `Phytoplankton Color Index` <dbl>, `Paralia sulcata [9000]` <dbl>,
    ## #   `Skeletonima costatum [9001]` <dbl>, `Thalassiosira [9002]` <dbl>,
    ## #   `Coscinodiscus [9003]` <dbl>, `Corethron criophilum [9004]` <dbl>,
    ## #   `Dactyliosolen antarcticus [9005]` <dbl>,
    ## #   `Leptocylindrus mediterraneus [9006]` <dbl>, …
