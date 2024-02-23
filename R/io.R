

#' Import data from a NFSC-cpr spreadsheet
#'
#' @export
#' @param filename char, the name of the file to read
#' @return list of tibbles with one sheet per element
import_cpr = function(filename = list_files(full.names= TRUE)[1]){
  
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