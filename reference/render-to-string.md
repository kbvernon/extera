# Render to String

Render specified template to string.

## Arguments

- template:

  character scalar, the name of the template to render.

- ...:

  specify context as key-value pairs where key is the template variable
  and value is the data to inject.

## Value

a single `character` string.

## Details

All context elements must be named.

## Examples

``` r
tera <- new_engine()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
)

tera$render_to_string(
  "hello-world",
  x = "world",
  y = "ExTera"
)
#> [1] "<p>Hello world. This is ExTera.</p>"
```
