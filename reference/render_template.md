# One-Off Template Rendering

For rendering a single template file, it may be preferable to use this
one-off rendering option.

## Usage

``` r
render_template(path, outfile = NULL, ...)
```

## Arguments

- path:

  character scalar, path to a template file

- outfile:

  character scalar, the path to file where template is to be rendered.
  If `NULL` (the default), it will render the template file to a string
  in the current R session.

- ...:

  specify context as key-value pairs where key is the template variable
  and value is the data to inject.

## Value

outfile (invisibly)

## Details

Requires a path to a template file, not a template string.

## Examples

``` r
outdir <- tempdir()

tmp <- file.path(
  outdir,
  "hello-world-template.html"
)

writeLines(
  '<p>Hello {{ x }}. This is {{ y }}.</p>',
  con = tmp
)

outfile <- file.path(
  outdir,
  "hello-world-rendered.html"
)

# render to string
render_template(
  tmp,
  x = "world",
  y = "ExTera"
)
#> [1] "<p>Hello world. This is ExTera.</p>\n"

# render to file
render_template(
  tmp,
  outfile = outfile,
  x = "world",
  y = "ExTera"
)

readLines(outfile, warn = FALSE)
#> [1] "<p>Hello world. This is ExTera.</p>"
```
