foo <- function(x) {
  if (missing(x))  {
    cat("three")
    super::super()
  } else {
    cat(x)
    super::super("deux")
  }
}
