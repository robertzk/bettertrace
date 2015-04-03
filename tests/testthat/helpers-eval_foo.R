eval_in <- function(expr, file = "foo.R") {
  eval.parent(substitute({
    eval(bquote(magic_dump({
      interactive <- function(...) TRUE
      source(.(file.path(tempdir, file)), keep.source = TRUE)
      expr
    })))
  }))
}
