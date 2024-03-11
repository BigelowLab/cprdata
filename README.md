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

> Part of this dataset was obtained from [NOAA’s
> NFSC](https://www.fisheries.noaa.gov/about/northeast-fisheries-science-center)
> on 20 January 2024 and might not represent the most up to date data.
> Please contact NOAA directly for the most recent data. The balance of
> this dataset is avaiable from the [NERACOOS ERDDAP
> server](https://www.neracoos.org/erddap/index.html).

## Requirements

- [R v4.1+](https://www.r-project.org/)
- [rlang](https://CRAN.R-project.org/package=rlang)
- [dplyr](https://CRAN.R-project.org/package=dplyr)
- [readxl](https://CRAN.R-project.org/package=readxl)
- [stringr](https://CRAN.R-project.org/package=stringr)
- [readr](https://CRAN.R-project.org/package=readr)

## Installation

    remotes::install_github("BigelowLab/nfsccrp")

## Usage

### Read the data

The dataset contains both zooplankton and phytoplankton data from the
Mid-Atlantic Bight and Gulf of Maine regions. We regularily access to
the zooplankton data, but it is easy to switch to phytoplankton. We can
read the data in its “raw” state as a simple table or transformed into a
[sf]() POINT table.

#### Read as a wide table

``` r
library(nfsccpr)
x = read_cpr(name = "zooplankton", form = "table") |>
  dplyr::glimpse()
```

    ## Rows: 5,697,206
    ## Columns: 10
    ## $ source    <chr> "nfsc", "nfsc", "nfsc", "nfsc", "nfsc", "nfsc", "nfsc", "nfs…
    ## $ cruise    <chr> "EG7107", "EG7107", "EG7107", "EG7107", "EG7107", "EG7107", …
    ## $ station   <dbl> 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, …
    ## $ time      <dttm> 1971-11-15 17:00:00, 1971-11-15 17:00:00, 1971-11-15 17:00:…
    ## $ lon       <dbl> 71.7666, 71.7666, 71.7666, 71.7666, 71.7666, 71.7666, 71.766…
    ## $ lat       <dbl> 39.6, 39.6, 39.6, 39.6, 39.6, 39.6, 39.6, 39.6, 39.6, 39.6, …
    ## $ pci       <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
    ## $ abundance <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
    ## $ name      <chr> "Unidentified plankton and fragments", "Copepoda", "Copepoda…
    ## $ stage     <chr> "unstaged", "nauplius", "copepodite V", "PARVA (POSTLARVA)",…

#### Read as a sf POINT table

``` r
x = read_cpr(name = "zooplankton",  form = "sf") |>
  dplyr::glimpse() 
```

    ## Rows: 5,697,206
    ## Columns: 9
    ## $ source    <chr> "nfsc", "nfsc", "nfsc", "nfsc", "nfsc", "nfsc", "nfsc", "nfs…
    ## $ cruise    <chr> "EG7107", "EG7107", "EG7107", "EG7107", "EG7107", "EG7107", …
    ## $ station   <dbl> 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, …
    ## $ time      <dttm> 1971-11-15 17:00:00, 1971-11-15 17:00:00, 1971-11-15 17:00:…
    ## $ pci       <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
    ## $ abundance <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
    ## $ name      <chr> "Unidentified plankton and fragments", "Copepoda", "Copepoda…
    ## $ stage     <chr> "unstaged", "nauplius", "copepodite V", "PARVA (POSTLARVA)",…
    ## $ geometry  <POINT [°]> POINT (71.7666 39.6), POINT (71.7666 39.6), POINT (71.…

### Import a raw data file

The NFSC data were shared as a large two-sheet Excel document. It’s
difficult to know if the format of the raw data file will remain as that
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

THe GMRI data files are formatted in long CSV files.
