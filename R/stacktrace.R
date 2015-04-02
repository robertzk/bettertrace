#' A traceback function to be used with error handling.
#'
#' To use, call \options{error = stacktrace}, which will be called
#' by default when this package is loaded.
stacktrace <- function() {
  n     <- length(sys.calls())
  trace <- Map(call_description, sys.calls(), sys.frames())
  msg   <- sanitize_message(geterrmessage())

  cat(
    paste(trace, collapse = "\n"), "\n\n", crayon::red(msg)
  )
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
  paste0("In ", frame_text(frame), ": ", call_text(call))
}

file_description <- function(call, frame, ref) {
  paste0("In ", ref_text(frame, ref))
}

ref_text <- function(frame, ref) {
  file <- attr(ref, "srcfile")$filename
  if (nzchar(file)) {
    file <- normalizePath(file)
    paste0(file, ":", ref[1L], ": ", trim_call(as.character(ref)))
  } else {
    frame_text(frame)
  }
}

frame_text <- function(frame) {
  if (identical(frame, .GlobalEnv)) {
    "global environment"
  } else if (nzchar(name <- environmentName(frame))) {
    if (grepl("^(package|imports):", name)) {
      paste("package", crayon::green(strsplit(name, ":")[[1]][2]))
    } else {
      paste("environment", name)
    }
  } else {
    frame_text(parent.env(frame))
  }
}

call_text <- function(call) {
  trim_call(paste(deparse(call), collapse = " "))
}

trim_call <- function(pre_call_text) {
  call_text <- strtrim(pre_call_text, 120)
  if (nchar(pre_call_text) > 120) {
    call_text <- paste0(call_text, " [...]")
  }
  call_text
}

sanitize_message <- function(msg) {
  strsplit(msg, " : ")[[1]][2]
}

