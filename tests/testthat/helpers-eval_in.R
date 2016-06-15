eval_in <- function(expr, sourcefile = "foo.R", global = FALSE, keep.source = TRUE) {
  force(sourcefile)
  paste(collapse = "\n", eval.parent(substitute({
    file <- tempfile()
    on.exit(unlink(file))
    try(silent = TRUE, capture.output(file = file,
      withCallingHandlers(error = function(e) bettertrace::stacktrace(), {
        source(file.path(tempdir, sourcefile),
          if (isTRUE(global)) globalenv() else environment(),
          keep.source = keep.source)
        expr
      })
    ))
    readLines(file, warn = FALSE)
  })))
}
