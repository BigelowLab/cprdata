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

## Requirements

- [R v4.1+](https://www.r-project.org/)
- [rlang](https://CRAN.R-project.org/package=rlang)
- [dplyr](https://CRAN.R-project.org/package=dplyr)
- [readxl](https://CRAN.R-project.org/package=readxl)
- [readr](https://CRAN.R-project.org/package=readr)

## Installation

    remotes::install_github("BigelowLab/nfsccrp")

## Usage

### Data path

The data is quiet sizeable to store in a package, so we provide a means
to set the data location outside of the package in a way that persists
between R sessions. You can set that path once and then forget it (or
you can change it at anytime.)

``` r
library(nfsccpr)

nfsccpr::set_path("/Users/ben/Library/CloudStorage/Dropbox/data/noaa/nmfs/cpr")
```

    ## [1] "/Users/ben/Library/CloudStorage/Dropbox/data/noaa/nmfs/cpr"

Presumably, you have placed a data file in that directory.

### List files in data path

``` r
ff = nfsccpr::list_files(full.names = TRUE)
ff
```

    ## [1] "/Users/ben/Library/CloudStorage/Dropbox/data/noaa/nmfs/cpr/MAB CPR (Jan 20, 2024 update).xlsx"

### Read a file

Reading the file yields once element for each included sheet.

``` r
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
