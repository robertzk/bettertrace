#' Overwrite base R's try to set error message timestamps.
#'
#' @note This is ultimately used to catch ctrl+C during interactive use.
evil_overwrite_try <- function() {
  if (!isTRUE(getOption("bettertrace.overwrite_try"))) return()

  # https://github.com/wch/r-source/blob/0230e46a85df66794506a54160709d4c4d4b2833/src/library/base/R/New-Internal.R#L47
  # Because try is the only guy in base R that sets the error message eventually
  # retrievable using geterrmessage, and there is no other way to detect
  # ctrl+C without modifying base R, we do some evil.
  unlockBinding("try", env = baseenv())
  body(try) <- body(evil_try)
  lockBinding("try", env = baseenv())

  packageStartupMessage("bettertrace.overwrite_try set, overwriting base::try")
}

# https://github.com/wch/r-source/blob/0230e46a85df66794506a54160709d4c4d4b2833/src/library/base/R/New-Internal.R#L21
evil_try <- function(expr, silent = FALSE) {
    tryCatch(expr, error = function(e) {
        call <- conditionCall(e)
        if (! is.null(call)) {
            ## Patch up the call to produce nicer result for testing as
            ## try(stop(...)).  This will need adjusting if the
            ## implementation of tryCatch changes.
            ## Use identical() since call[[1L]] can be non-atomic.
            if (identical(call[[1L]], quote(doTryCatch)))
                call <- sys.call(-4L)
            dcall <- deparse(call)[1L]
            prefix <- paste("Error in", dcall, ": ")
            LONG <- 75L # to match value in errors.c
            msg <- conditionMessage(e)
            sm <- strsplit(msg, "\n")[[1L]]
            w <- 14L + nchar(dcall, type="w") + nchar(sm[1L], type="w")
            ## this could be NA if any of this is invalid in a MBCS
            if(is.na(w))
                w <-  14L + nchar(dcall, type="b") + nchar(sm[1L], type="b")
            if (w > LONG)
                prefix <- paste0(prefix, "\n  ")
        }
        else prefix <- "Error : "
        msg <- paste0(prefix, conditionMessage(e), "\n")
        ## Store the error message for legacy uses of try() with
        ## geterrmessage().
        
        #### MAGIC HACK ####
        env <- get(".bettertrace_env", envir = getNamespace("bettertrace"))
        env$timestamp <- Sys.time()

        .Internal(seterrmessage(msg[1L]))
        if (! silent && identical(getOption("show.error.messages"), TRUE)) {
            cat(msg, file = stderr())
            .Internal(printDeferredWarnings())
        }
        invisible(structure(msg, class = "try-error", condition = e))
    })
}

