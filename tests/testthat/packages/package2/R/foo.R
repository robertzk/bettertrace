foo <- function(x) {
  if (missing(x))  {
    cat("two")
    super::super()
  } else {
    cat(x)
    super::super("un")
  }
}
