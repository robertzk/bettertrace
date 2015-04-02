#' A traceback function to be used with error handling.
#'
#' To use, call \options{error = stacktrace}, which will be called
#' by default when this package is loaded.
stacktrace <- function() {
  Map(call_description, sys.calls(), sys.frames())

}

call_description <- function(call, frame) {
  srcref <- attr(call, "srcref")
  if (is.null(srcref)) {
    package_description(call, frame)
  } else {
    file_description(call, frame)
  }
}

package_description <- function(call, frame) {
}
