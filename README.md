Better Stack Trace for R [![Build Status](https://travis-ci.org/robertzk/bettertrace)](https://travis-ci.org/robertzk/bettertrace.svg) [![Coverage Status](https://coveralls.io/repos/robertzk/bettertrace/badge.svg?branch=master)](https://coveralls.io/r/robertzk/bettertrace)
===========

R has long suffered from poor stack tracing capabilities. This package aims to make
the situation slightly better by providing more details when errors occur.

For example, if we have a file `"/Users/robertk/tmp/foo.R"`,

```R
# /Users/robertk/tmp/foo.R
foo <- function() { bar() + 1 }
bar <- function() { baz() + 2 }
```

then sourcing and calling `foo` gives

```R
# R console
source("~/tmp/foo.R")
foo()
# Error in bar() : could not find function "baz"
# In global environment: foo()
# In /Users/robertk/tmp/foo.R:1: bar() + 1
# In /Users/robertk/tmp/foo.R:2: baz() + 2
# 
# could not find function "baz"
```

This is much more informative than the built-in message:

```
> foo()
Error in bar() : could not find function "baz"
```

Installation
------------

This package is not yet available from CRAN (as of April 2, 2015).
To install the latest development builds directly from GitHub, run this instead:

```R
if (!require("devtools")) install.packages("devtools")
devtools::install_github("robertzk/bettertrace")
library(bettertrace) # options(error = bettertrace::stacktrace) will be set
```



