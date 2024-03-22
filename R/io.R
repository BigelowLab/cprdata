# > glimpse(nfsc)
# Rows: 2,755,662
# Columns: 12
# $ Cruise                      <chr> "EG7107", "EG7107", "EG…
# $ Station                     <dbl> 43, 43, 43, 43, 43, 43,…
# $ Year                        <dbl> 1971, 1971, 1971, 1971,…
# $ Month                       <dbl> 11, 11, 11, 11, 11, 11,…
# $ Day                         <dbl> 15, 15, 15, 15, 15, 15,…
# $ Hour                        <dbl> 17, 17, 17, 17, 17, 17,…
# $ Minute                      <dbl> 0, 0, 0, 0, 0, 0, 0, 0,…
# $ `Latitude (degrees)`        <dbl> 39.6, 39.6, 39.6, 39.6,…
# $ `Longitude (degrees)`       <dbl> 71.7666, 71.7666, 71.76…
# $ `Phytoplankton Color Index` <dbl> 1, 1, 1, 1, 1, 1, 1, 1,…
# $ name                        <chr> "Unidentified plankton …
# $ abundance                   <dbl> 0, 0, 0, 0, 0, 0, 0, 0,…
# 
# > glimpse(gmri)
# Rows: 2,941,544
# Columns: 10
# $ cruise          <chr> "EG6101", "EG6101", "EG6101", "EG61…
# $ transect_number <dbl> 15, 15, 15, 15, 15, 15, 15, 15, 15,…
# $ time            <dttm> 1961-07-16 04:00:00, 1961-07-16 04…
# $ latitude        <dbl> 43.25, 43.25, 43.25, 43.25, 43.25, …
# $ longitude       <dbl> 66, 66, 66, 66, 66, 66, 66, 66, 66,…
# $ pci             <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
# $ taxon           <chr> "Absent", "Acartia", "Acartia", "Ac…
# $ taxon_stage     <chr> "unstaged", "adult", "copepodite i-…
# $ aphia_id        <dbl> NaN, NaN, NaN, NaN, NaN, NaN, NaN, …
# $ abundance       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…


#' Harmonize GMRI and NFSC CPR datasets
#' 
#' @export
#' @param x long-form table of NFSC data
#' @param y table of GMRI data
#' @param is_zoo logical, if TRUE then account for taxon stage
#' @return list of two tables with the same form, one for nfsc and gmri
harmonize_cpr = function(x = read_nfsc_cpr(), 
                         y = read_gmri_cpr(),
                         is_zoo = "taxon_stage" %in% names(y)){
  # source
  # cruise
  # station/transect
  # time POSIXct
  # lon
  # lat
  # pci
  # name
  # (stage if zooplankton)
  # abundance
  nms = c("source", "cruise", "station", "time", "lon", "lat", "pci", "abundance", "name")
  if (is_zoo) nms = c(nms, "stage")
  dt = sprintf("%0.4i-%0.2i-%0.2iT%0.2i:%0.2i:00", 
               x$Year, x$Month, x$Day, x$Hour, x$Minute)
  x = x |>
    dplyr::mutate(source = "nfsc",
                  time = as.POSIXct(dt, 
                                    format = "%Y-%m-%dT%H:%M:%S", 
                                    tz = "UTC")) |>
    dplyr::rename(
      cruise = "Cruise",
      station = "Station",
      pci = "Phytoplankton Color Index",
      lat = "Latitude (degrees)",
      lon = "Longitude (degrees)"
    )
  
  
  
  y = y |>
    dplyr::rename(
      lat = "latitude",
      lon = "longitude",
      station = "transect_number",
      name = "taxon" ) |>
    dplyr::mutate(source = "gmri")
  
  if (is_zoo) {
    x = nfsc_cpr_extract_stage(x) # dplyr::mutate(x, stage = NA_character_)
    y = dplyr::rename(y, stage = "taxon_stage")
  }
  
  dplyr::bind_rows(
    dplyr::select(x, dplyr::all_of(nms)),
    dplyr::select(y, dplyr::all_of(nms))
  )
  
}

#' Given a nfsc cpr table split name and stage
#' 
#' @export
#' @param x table, the nfsc cpr data (long format)
#' @return the tabkle with updated name and stage columns
nfsc_cpr_extract_stage = function(x){
  
  dplyr::mutate(x,
                stage = stringr::str_extract(.data$name, "(?<=\\[).+?(?=\\])"),
                name = stringr::word(.data$name, 1, sep = "\\s\\["))
} 


#' Read NFSC data exported freom NFSC Excel spreadsheet
#' 
#' @export
#' @param filename, the name of the file to read
#' @param repair_longitude logi, if TRUE then make all longitudes negative
#' @return table of data
read_nfsc_cpr = function(
    filename = system.file("nfsc/2024-01-20_zooplankton.csv.gz",
                           package = 'nfsccpr'),
    repair_longitude = TRUE){
  x = readr::read_csv(filename, show_col_types = FALSE) |>
    nfsc_cpr_to_long()
  if (repair_longitude) x[["Longitude (degrees)"]] =  0.0 - abs(x[["Longitude (degrees)"]])
  x
}

#' Read GMRI data downloaded by NERACOOS
#' 
#' @export
#' @param filename, the name of the file to read
#' @param repair_longitude logi, if TRUE then make all longitudes negative
#' @return table of data (with units as an attribute)
read_gmri_cpr = function(
    filename = system.file("gmri/2024-03-08_gom_cpr_zooplankton_full_bdeb_74de_8e13.csv.gz",
                           package = 'nfsccpr'),
    repair_longitude = TRUE){
  conn = gzfile(filename, open = "rt")
  hdr = readLines(conn, n = 2)
  col_names = strsplit(hdr[1], ",", fixed = TRUE)[[1]]
  close(conn)
  x = readr::read_csv(filename,
                      skip = 2,
                      col_names = col_names,
                      show_col_types = FALSE)
  if (repair_longitude) x[["longitude"]] =  0.0 - abs(x[["longitude"]])
  attr(x, "units") <- strsplit(hdr[2], ",", fixed = TRUE)[[1]] 
  x
}





#' Read zooplankton or phytoplankton CPR data
#' 
#' @export
#' @param name chr, the name of the dataset to read (zooplankton or phytoplankton).
#'   Can be shortened to "zoo" or "phyto".
#' @param form char, one of 'table' or 'sf' to determine the output form
#' @param composite logical, if TRUE read the composite (merged and 
#' simplified) dataset.
#' @param clean logical, if TRUE then try to clean up the name and stage (if present)
#'   variable(s).
#' @return either a tibble or sf-table
read_cpr = function(name = 'zooplankton',
                    form = c("table", "sf")[1],
                    composite = TRUE,
                    clean = !composite){
  
  if (FALSE){
    name = c('zooplankton',  "phytoplankton")[1]
    form = c("table", "sf")[1]
    composite = FALSE # TRUE
    clean = TRUE
  }
  
  most_recent_file = function(path,  pattern = "^.*_zooplankton\\.csv\\.gz$"){
    ff = list.files(path, pattern = pattern, full.names = TRUE)
    ff[[length(ff)]]
  }
  
  
  if (composite){
    
    path = system.file("composite", package = "nfsccpr")
    filename = switch(substring(tolower(name[1]),1,1),
                      "z" = most_recent_file(path, pattern = "^.*zooplankton.*\\.rds$"),
                      "p" = most_recent_file(path, pattern = "^.*phytoplankton.*\\.rds$"),
                      stop("name not known:", name[1]))
    x = readRDS(filename)
    
  } else {
    
    nfscpath = system.file("nfsc", package = "nfsccpr")
    gmripath = system.file("gmri", package = "nfsccpr")
    
    filename = switch(substring(tolower(name[1]),1,1),
      "z" = most_recent_file(nfscpath, pattern = "^.*_zooplankton\\.csv\\.gz$"),
      "p" = most_recent_file(nfscpath, pattern = "^.*_phytoplankton\\.csv\\.gz$"),
      stop("name not known:", name[1]))
    
    nfsc = read_nfsc_cpr(filename)
    
    filename = switch(substring(tolower(name[1]),1,1),
                      "z" = most_recent_file(gmripath, pattern = "^.*zooplankton.*\\.csv\\.gz$"),
                      "p" = most_recent_file(gmripath, pattern = "^.*phytoplankton.*\\.csv\\.gz$"),
                      stop("name not known:", name[1]))
    
    gmri = read_gmri_cpr(filename)
    
    x = harmonize_cpr(nfsc, gmri)
    
    if (clean){
      # strip leading/trailing spaces and reduce inners to just one
      # first cap others lower case
      x = dplyr::mutate(x, 
        name = stringr::str_squish(.data$name) |>
          stringr::str_to_sentence())
      if ("stage" %in% colnames(x)){
          # all lower case
        x = dplyr::mutate(x,
          stage = stage_clean(.data$stage) |> recode_stage() )
      } # stage?
    } # clean?
    
  }
  
  if (tolower(form[1]) == "sf"){
    x = cpr_as_sf(x)
  }
  
  x
}

# a private function for the developer
write_composite = function(x = read_cpr("zooplankton", 
                                        composite = FALSE, 
                                        clean = TRUE)){
  if ("stage" %in% colnames(x)){
    filename = sprintf("inst/composite/%s_zooplankton.rds", 
                       format(Sys.Date(), "%Y-%m-%d"))
  } else {
    filename = filename = sprintf("inst/composite/%s_phytoplankton.rds", 
                                  format(Sys.Date(), "%Y-%m-%d"))
  }
  saveRDS(x, filename)
  x
}


#' Pivot CPR data to long form
#' 
#' @export
#' @param x tibble of data
#' @param retain_col char, the name of the column signaling the start
#'   of the columns to pivot
#' @return long-form tibble of data
nfsc_cpr_to_long = function(x,
                       retain_col = "Phytoplankton Color Index"){
  
  ix = which(names(x) == retain_col[1])
  tidyr::pivot_longer(x,
                     cols = seq(from = ix + 1, to = ncol(x), by = 1),
                     names_to = "name",
                     values_to = "abundance")
}


#' Convert CPR data to sf
#' 
#' @export
#' @param x tibble of data
#' @param coords char, the names of the x and y coordinates
#' @param crs crs to assign during transform
#' @return sf class POINT
cpr_as_sf = function(x,
                     coords = c("lon", "lat"), 
                     crs = 4326){
  sf::st_as_sf(x, coords = coords, crs = crs)
}


###########################################


#' Import data from a NFSC-cpr spreadsheet
#'
#' @export
#' @param filename char, the name of the file to read
#' @return list of tibbles with one sheet per element
import_cpr = function(filename){
  
  if (basename(filename) == "MAB CPR (Jan 20, 2024 update).xlsx"){
    r = import_mab_20240120(filename)
  } else {
    stop("filename not known - contact package maintainer")
  }
  
  r
}


import_mab_20240120 = function(filename){
  sheets = readxl::excel_sheets(filename)
  # [1] "Zooplankton"   "Phytoplankton"
  
  Zooplankton = function(filename){
    hdr = readxl::read_excel(filename, sheet = "Zooplankton",
                             range = readxl::cell_rows(9:13),
                             col_types = "text",
                             .name_repair = "minimal")
    hdr = rlang::set_names(hdr, paste0("x", seq_len(ncol(hdr))))
    nms = gsub("'", "", hdr[1,], fixed = TRUE)
    stg = sprintf("[%s]", gsub("'", "", hdr[2,], fixed = TRUE))
    code = sprintf("[%s]", paste(hdr[3,], hdr[4,], sep = "."))
    ix = seq(from = 11, to = length(nms), by = 1)
    nms[ix] = paste(nms[ix], stg[ix], code[ix])
    
    readxl::read_excel(filename, sheet = "Zooplankton",
                       skip = 13,
                       na = c("", "NaN", "NAN", "NA"),
                       col_names = nms) |>
      dplyr::mutate(Cruise = gsub("'", "", .data$Cruise, fixed = TRUE))
    
  }
  
  Phytoplankton = function(filename){
    hdr = readxl::read_excel(filename, sheet = "Phytoplankton",
                             range = readxl::cell_rows(9:11),
                             col_types = "text",
                             .name_repair = "minimal")
    hdr = rlang::set_names(hdr, paste0("x", seq_len(ncol(hdr))))
    nms = gsub("'", "", hdr[1,], fixed = TRUE)
    ix = seq(from = 11, to = length(nms), by = 1)
    nms[ix] = paste(nms[ix], sprintf("[%s]", hdr[2,ix]))
    
    readxl::read_excel(filename, sheet = "Phytoplankton",
                      skip = 11,
                      na = c("", "NaN", "NAN", "NA"),
                      col_names = nms) |>
      dplyr::mutate(Cruise = gsub("'", "", .data$Cruise, fixed = TRUE))
  }
  
  list(Zooplankton = Zooplankton(filename),
       Phytoplankton = Phytoplankton(filename))
}