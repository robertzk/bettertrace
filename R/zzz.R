`%||%` <- function(x, y) if (is.null(x)) y else x

.bettertrace_env <- new.env()

.onLoad <- function(libPath, pkgName) {
  packageStartupMessage("Package ", sQuote("bettertrace"), " overwriting ",
                        sQuote('options("error")'), "\n")
  .bettertrace_env$error <- getOption("error")
  options(error = stacktrace)
}

.onUnLoad <- function() {
  options(error = .bettertrace_env$error)
}

