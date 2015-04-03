context("load and unload hooks")
library(testthatsomemore)

test_that("load hook works", {
  .onLoad("foo", "bar")
  around <- function(x) x[-c(1, length(x))]
  expect_identical(around(deparse(getOption("error"))),
                   around(deparse(stacktrace)))
})

test_that("unload hook works", {
  expect_equal(
    package_stub("base", "options", function(error) {
      deparse(substitute(error))
    }, .onUnLoad()),
    "previous_error$error"
  )
})
