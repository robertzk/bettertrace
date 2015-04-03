with_options <- function(...) {
  opts  <- eval(substitute(alist(...)))
  names <- names(opts) %||% character(length(opts))

  opt_call <- list()
  for (name in names[!nzchar(names)]) {
    opt_call[[name]] <- eval.parent(opts[[name]])
  }

  if (length(opt_call) > 0L) {
    old_opts <- do.call(options, opt_call)
    on.exit(options(old_opts), add = TRUE)
  }

  for (name in names[nzchar(names)]) {
    eval.parent(opts[[name]])
  }
}
