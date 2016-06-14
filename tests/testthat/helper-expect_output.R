expect_output <- function(expr, value, ..., positive = TRUE) {
  output  <- paste(capture.output(expr), collapse = "\n")
  matches <- grepl(value, output, ...)
  if (isTRUE(positive)) {
    expect_true(matches)
  } else {
    expect_false(matches)
  }
}

