context("stacktrace")
library(testthatsomemore)

with_options(error = stacktrace, { 
  test_that("it does not print a stacktrace on a simple error", {
    expect_output(try(silent = TRUE, foob()), "")
  })

  test_that("it prints a nice stacktrace on a more involved error", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      expect_match(eval_in(foo()), "foo\\.R:2: bar\\(\\) \\+ 1")
      expect_match(eval_in(foo()), "foo\\.R:3: baz\\(\\) \\+ 1")
    })
  })

  test_that("it prints a stack trace with a custom package", {
    within_file_structure(list("foo.R" = "
      faw <- function(...) { bar(...) + 1 }
      bar <- function(...) { foo(...) + 1 }
    "), {
      devtools::load_all("packages/package1")
      expect_output(eval_in(foo()), "one")
      expect_output(eval_in(foo(1)), "one", positive = FALSE)
      expect_output(eval_in(foo(1)), "package package1: foo\\(1\\)")
      expect_output(eval_in(foo(1)), "foo\\.R:5: squawk\\(\\)")
    })
  })

  test_that("prints the error message nicely", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      package_stub("base", "geterrmessage", function(...) "Error: errmsgyo",
        expect_match(eval_in(foo()), "Error: errmsgyo")
      )
      package_stub("base", "geterrmessage", function(...) "Error: errmsgyo\033",
        expect_match(eval_in(foo()), "Error: errmsgyo\033")
      )
    })
  })

  test_that("it cannot match filenames if the srcref has no file", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      expect_false(grepl("foo\\.R:", eval_in(foo(), keep.source = FALSE)))
    })
  })

  test_that("it cannot match filenames if the srcref has no file (mocked)", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      package_stub("bettertrace", "ref_filename", function(ref) "", 
        expect_output(eval_in(foo()), "foo\\.R:", positive = FALSE))
    })
  })

  test_that("It can see it is getting called from a local environment", {
    on.exit(rm(list = c("foo", "bar"), envir = .GlobalEnv), add = TRUE)
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      expect_match(eval_in(foo(), global = TRUE), "In <environment: 0x[0-9a-f]+>: foo()")
    })
  })

  test_that("it can print a non-namespace name", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
    "), {
      package_stub("bettertrace", "is.namespace", function(...) FALSE,
        expect_match(eval_in(foo()), "In environment"))
    })
  })

  test_that("it can use custom environment labels", {
    within_file_structure(list("foo.R" = "
      foo <- function() { bar() + 1 }
      bar <- function() { baz() + 1 }
      attr(environment(foo), 'stacktrace_label') <- 'foo function'
    "), {
      package_stub("bettertrace", "is.namespace", function(...) FALSE, {
        output <- eval_in(foo(), keep.source = FALSE)
        expect_match(output, "In foo function:")
      })
    })
  })
})
