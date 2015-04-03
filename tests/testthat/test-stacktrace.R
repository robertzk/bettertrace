context("stacktrace")
library(testthatsomemore)

with_options(error = stacktrace, { 
  test_that("it does not print a stacktrace on a simple error", {
    expect_output(try(silent = TRUE, foo()), "")
  })

  test_that("it prints a nice stacktrace on a more involved error", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
      bar() + 1
    "), {
      debugonce(stacktrace)
      source(file.path(tempdir, "foo.R"))
    })
  })
})
