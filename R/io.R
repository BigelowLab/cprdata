#' Read zooplankton or phytoplankton CPR data
#' 
#' @export
#' @param name chr, the name of the dataset to read (zooplankton or phytoplankton).
#'   Can be shortened to "zoo" or "phyto".
#' @param long logical, if TRUE pivot the data to long from
#' @param form char, one of 'table' or 'sf' to determine the output form
#' @return either a tibble or sf-table
read_cpr = function(name = 'zooplankton',
                    long = FALSE,
                    form = c("table", "sf")[1]){
  
  path = system.file("nfsc", package = "nfsccpr")
  
  most_recent_file = function(path,  pattern = "^.*_zooplankton\\.csv\\.gz$"){
    ff = list.files(path, pattern = pattern, full.names = TRUE)
    ff[[length(ff)]]
  }
  
  filename = switch(substring(tolower(name[1]),1,1),
    "z" = most_recent_file(path, pattern = "^.*_zooplankton\\.csv\\.gz$"),
    "p" = most_recent_file(path, pattern = "^.*_phytoplankton\\.csv\\.gz$"),
    stop("name not known:", name[1]))
  
  x = readr::read_csv(filename, show_col_types = FALSE)
  
  if (long){
    x = cpr_to_long(x)
  }
  
  if (tolower(form[1]) == "sf"){
    x = cpr_as_sf(x)
  }
  
  x
}

#' Pivot CPR data to long form
#' 
#' @export
#' @param x tibble of data
#' @return long-form tibble of data
cpr_to_long = function(x,
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
                     coords = c("Longitude (degrees)", "Latitude (degrees)"), 
                     crs = 4326){
  sf::st_as_sf(x, coords = c("Longitude (degrees)", "Latitude (degrees)"), crs = 4326)
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