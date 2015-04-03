# Since testthat hijacks the conditioning system, we cannot test
# the stacktrace function in the usual way! Instead, we print the output
# to a file and analyze it retroactively.
magic_dump <- function(call) {
  file <- tempfile()
  call <- substitute({
    options(error = bettertrace::stacktrace) 
    call
  })
  squish <- function(x) paste(x, collapse = "\n")
  writeLines(squish(deparse(call)), file)
  squish(system(
    sprintf("Rscript -e 'source(\"%s\")'", file),
    intern = TRUE, ignore.stderr = TRUE
  ))
}
