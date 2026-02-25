# Render Template to File

Use `$render()` to render specified template to file.

## Usage

``` r
render(template, outfile, ...)
```

## Arguments

- template:

  character scalar, the name of the template to render.

- outfile:

  character scalar, the path to file where template is to be rendered.

- ...:

  specify context as key-value pairs where key is the template variable
  and value is the data to inject.

## Value

`outfile` (invisibly)

## Details

All context elements must be named.

## Examples

``` r
tera <- ExTera$new()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
)

outfile <- file.path(tempdir(), "rendered-hello-world.html")

tera$render(
  "hello-world",
  outfile = outfile,
  x = "world",
  y = "ExTera"
)

readLines(outfile, warn = FALSE)
#> [1] "<p>Hello world. This is ExTera.</p>"
```
