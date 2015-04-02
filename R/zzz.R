previous_error <- new.env()

.onLoad <- function(pkgName, libPath) {
  packageStartupMessage("Package ", sQuote("bettertrace"), " overwriting ", sQuote('options("error")'), "\n")
  previous_error$error <- getOption("error")
  options(error = stacktrace)
}

.onUnLoad <- function() {
  options(error = previous_error$error)
}

