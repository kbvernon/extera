# Render Template to String

Use `$render_to_string()` to render specified template to string.

## Usage

``` r
render_to_string(template, ...)
```

## Arguments

- template:

  character scalar, the name of the template to render.

- ...:

  specify context as key-value pairs where key is the template variable
  and value is the data to inject.

## Value

Rendered string.

## Details

All context elements must be named.

## Examples

``` r
tera <- ExTera$new()

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
