#' A traceback function to be used with error handling.
#'
#' To use, call \options{error = stacktrace}, which will be called
#' by default when this package is loaded.
#'
#' @export
#' @examples
#' \dontrun{
#'   # /Users/you/tmp/foo.R
#'   foo <- function() { bar() + 1 }
#'   bar <- function() { baz() + 2 }
#'  
#'   # R console
#'   source("~/tmp/foo.R")
#'   foo()
#'   # Error in bar() : could not find function "baz"
#'   # In global environment: foo()
#'   # In /Users/robertk/tmp/foo.R:1: bar() + 1
#'   # In /Users/robertk/tmp/foo.R:2: baz() + 2
#'   # 
#'   # could not find function "baz"
#' }
stacktrace <- function() {
  n     <- length(sys.calls())
  trace <- Map(call_description, sys.calls(), sys.frames())
  trace <- strip_hidden(trace)
  msg   <- sanitize_message(geterrmessage())

  if (length(trace) > 1) {
    cat(sep = "",
      paste(trace, collapse = "\n"), "\n\n",
      if (!is.na(msg)) {
        paste0(crayon::bold("Error"), ": ", safe_color(msg, "red"))
      }
    )
  }
  invisible(trace)
}

call_description <- function(call, frame) {
  srcref <- attr(call, "srcref")
  if (is.null(srcref)) {
    package_description(call, frame)
  } else {
    file_description(call, frame, srcref)
  }
}

package_description <- function(call, frame) {
  frame_info <- frame_text(frame)
  text <- paste0("In ", frame_info, ": ", call_text(call))
  if (!is.null(pkg <- attr(frame_info, "pkg"))) {
    attr(text, "pkg") <- pkg
  }
  text
}

file_description <- function(call, frame, ref) {
  paste0("In ", ref_text(frame, ref))
}

ref_text <- function(frame, ref) {
  file <- attr(ref, "srcfile")$filename
  if (nzchar(file)) {
    file <- normalizePath(file)
    paste0(decorate_file(file), ":", crayon::bold(as.character(ref[1L])),
           ": ", trim_call(as.character(ref)))
  } else {
    frame_text(frame)
  }
}

frame_text <- function(frame) {
  if (identical(frame, .GlobalEnv)) {
    structure(pkg = "_global",
      "global environment"
    )
  } else if (nzchar(name <- environmentName(frame))) {
    if (isNamespace(frame)) {
      structure(pkg = name,
        paste("package", crayon::green(as.character(name)))
      )
    # TODO: (RK) Temporarily disabled until I figure out if there is a way
    # to tell between namespace and package env calls on the stack trace!
    # } else if (grepl("^(package|imports):", name)) {
    #  pkg_name <- strsplit(name, ":")[[1]][2]
    #  structure(pkg = pkg_name,
    #    paste("package", crayon::green(pkg_name))
    #  )
    } else {
      paste("environment", name)
    }
  } else {
    # TODO: (RK) Pre-compute cache of environments.
    frame_text <- frame_text(parent.env(frame))
    if (identical(attr(frame_text, "pkg"), "_global")) {
      capture.output(print(frame))
    } else {
      frame_text
    }
  }
}

call_text <- function(call) {
  trim_call(paste(deparse(call), collapse = " "))
}

trim_call <- function(pre_call_text) {
  pre_call_text <- paste(pre_call_text, collapse = "\n")
  call_text <- strtrim(pre_call_text, 120)
  if (nchar(pre_call_text) > 120) {
    call_text <- paste0(call_text, " [...]")
  }
  call_text
}

sanitize_message <- function(msg) {
  strsplit(msg, ": ")[[1]][2]
}

strip_hidden <- function(trace) {
  Filter(function(line) {
    !identical(attr(line, "pkg"), "bettertrace")
  }, trace)
}

safe_color <- function(msg, color) {
  if (grepl("\033", msg, fixed = TRUE)) {
    msg
  } else {
    get(color)(msg)
  }
}

decorate_file <- function(file) {
  file.path(dirname(file), crayon::yellow(basename(file)))
}
