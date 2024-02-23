#' Set the data path
#' 
#' @export
#' @param path char, the data path where your XLSX file is stored
#' @param filename char, the name of the file where you will store the path.
#'   Best to allow this to be the default.
#' @return the data path
set_path = function(path = ".", filename = "~/.nfsc-cpr"){
  writeLines(path, con = filename)
  path
}

#' Get the data path
#' 
#' @export
#' @param filename char, the file where the data path is stored.
#'   Best to allow this to be the default.
#' @return the data path
get_path = function(filename = "~/.nfsc-cpr"){
  readLines(filename)
}

#' List the data files stored in the path
#' 
#' @export
#' @param pattern char, the regex pattern to search for.  Use 
#'   \code{glob2rx()} to convert globs to regular expressions.
#' @param path char the data path
#' @param ... other arguments for \code{list.files()}
#' @return zero or more filenames
list_files = function(pattern =  "^.*\\.xlsx$",
                      path = get_path(),
                      ...){
  list.files(path, pattern = pattern, ...)
}
