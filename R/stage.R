#' Clean a vector of stages
#' 
#' @export
#' @param x chr a character vector of stages
#' @return the input in sentence-case and spaces minimized 
stage_clean = function(x){
  stringr::str_squish(x) |>
    tolower()
}

#' Read the stage recoding look up table (lut)
#'
#' @export
#' @param filename chr , the name of the file to read
#' @param form chr, one of "table" or "vector"
#' @return table of name and newname or a charcater named vector of name = newname 
read_stage_lut = function(filename = system.file("stage/stage_lut.csv", 
                                                 package = "nfsccpr"),
                          form = c("table", "vector")[1]){
  lut = readr::read_csv(filename, show_col_types = FALSE)
  if (tolower(form == "vector")){
    nm = lut$stage
    lut = lut$newname |>
      rlang::set_names(nm)
  }
  lut
}

#' Make the beginnings of a LUT for managing stage names
#' 
#' This provides and intermediary step, the output "newname" column
#' should be adjusted, then the table saved as inst/stage/stage_lut.csv
#' 
#' @param x table of unadultered data
#' @return a table of name, n (count) and newname
make_stage_lut = function(x = read_cpr("zooplankton", 
                                 composite = FALSE,
                                 clean = FALSE)){
  
  lut = dplyr::count(x, dplyr::all_of("stage")) |>
    dplyr::mutate(newname = stage_clean(.data$stage))
  
  lut
}

#' Recode values of stage to a uniform coding
#' 
#' @export
#' @param x chr, vector of stage names
#' @param lut vector look up in the form of named vector
#' @return character vector with zero or more elements recoded
recode_stage = function(x, lut = read_stage_lut(form = "vector")){
  ix = x %in% names(lut)
  if (any(!ix)){
    warning("these stages are unknown and will be unchanged:",
            paste(x[!ix], collapse = ", "))
  }
  x[ix] = lut[x[ix]]
  x
}