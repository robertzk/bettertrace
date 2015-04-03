context("stacktrace")
library(testthatsomemore)

with_options(error = stacktrace, { 
  test_that("it does not print a stacktrace on a simple error", {
    expect_output(try(silent = TRUE, foo()), "")
  })

  test_that("it prints a nice stacktrace on a more involved error", {
    on.exit(rm(list = c("foo", "bar"), envir = .GlobalEnv), add = TRUE)
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      expect_match(eval_in(foo()), "foo\\.R:2: bar\\(\\) \\+ 1")
      expect_match(eval_in(foo()), "foo\\.R:3: baz\\(\\) \\+ 1")
    })
  })

  test_that("it prints a stack trace with a custom package", {
    on.exit(rm(list = c("faw", "bar"), envir = .GlobalEnv), add = TRUE)
    within_file_structure(list("foo.R" = "
      faw <- function(...) { bar(...) + 1 }
      bar <- function(...) { foo(...) + 1 }
    "), {
      load_all("packages/package1")
      expect_output(eval_in(foo()), "one")
      not(expect_output)(eval_in(foo(1)), "one")
      expect_output(eval_in(foo(1)), "package package1: foo\\(1\\)")
      expect_output(eval_in(foo(1)), "foo\\.R:5: squawk\\(\\)")
    })
  })

  test_that("prints the error message nicely", {
    on.exit(rm(list = c("foo", "bar"), envir = .GlobalEnv), add = TRUE)
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      package_stub("base", "geterrmessage", function(...) "Error: errmsgyo",
        expect_match(eval_in(foo()), "Error: errmsgyo")
      )
      package_stub("base", "geterrmessage", function(...) "Error: errmsgyo\033",
        expect_match(eval_in(foo()), "Error: errmsgyo")
      )
    })
  })

  test_that("it cannot match filenames if the srcref has no file", {
    on.exit(rm(list = c("foo", "bar"), envir = .GlobalEnv), add = TRUE)
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      not(expect_match)(eval_in(foo(), keep.source = FALSE), "foo\\.R")
    })
  })

  test_that("it cannot match filenames if the srcref has no file (mocked)", {
    on.exit(rm(list = c("foo", "bar"), envir = .GlobalEnv), add = TRUE)
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      package_stub("base", "attr", function(x, which) {
        out <- .Primitive("attr")(x, which)
        if ("filename" %in% names(out) && nzchar(out$filename)) 
          out$filename <- ""
        out
      }, 
        not(expect_match)(eval_in(foo()), "foo\\.R")
      )
    })
  })
})
