# Version 0.1.3

  * Fix error message filtering so that it does not remove "foo" 
    in "error: foo: bar"

# Version 0.1.2

  * Environments with a `stacktrace_label` attribute display a custom
    message in the stacktrace. For example, if a function `f` is called
    with `attr(environment(f), "stacktrace_label") <- "special function"`,
    the stacktrace shown will include a line "In special function: ...".

# Version 0.1.1

  * Fixed a bug wherein pressing Ctrl+C within `browser` unnecessarily printed 
    a stack trace.

# Version 0.1.0

  * The initial creation of the package. 
