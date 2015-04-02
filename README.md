Better Stack Trace for R [![Build Status](https://travis-ci.org/robertzk/bettertrace)](https://travis-ci.org/robertzk/bettertrace.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/robertzk/bettertrace/badge.svg?branch=master)](https://coveralls.io/r/robertzk/bettertrace)
===========

R has long suffered from poor stack tracing capabilities. This package aims to make
the situation slightly better by providing more details when errors occur.

Installation
------------

This package is not yet available from CRAN (as of April 2, 2015).
To install the latest development builds directly from GitHub, run this instead:

```R
if (!require("devtools")) install.packages("devtools")
devtools::install_github("robertzk/bettertrace")
```



