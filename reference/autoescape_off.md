# Turn Off Autoescaping

Use `$autoescape_off()` to turn off autoescaping of HTML.

## Usage

``` r
autoescape_off()
```

## Value

Self (invisibly)

## Details

Autoescaping is on by default.

## Examples

``` r
tera <- ExTera$new()

tera$add_string_templates(
  "hello-world.html" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
)

tera$autoescape_off()
#> ✔ Autoescaping is now off!

tera$render_to_string(
  "hello-world.html",
  x = "&world",
  y = "an apostrophe, '"
)
#> [1] "<p>Hello &world. This is an apostrophe, '.</p>"
```
