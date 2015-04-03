eval_in <- function(expr, file = "foo.R", keep.source = TRUE) {
  paste(collapse = "\n", eval.parent(substitute({
    file <- tempfile()
    on.exit(unlink(file))
    try(silent = TRUE, capture.output(file = file,
      withCallingHandlers(error = function(e) stacktrace(), {
        source(file.path(tempdir, file), keep.source = keep.source)
        expr
      })
    ))
    readLines(file)
  })))
}
