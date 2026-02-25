# Autoescaping

Turn autoescaping of HTML on or off. Autoescaping is on by default.

## Value

Self (invisibly)

## Details

Autoescaping only applies to templates whose names end with ".html",
".htm", or ".xml".

## Examples

``` r
tera <- new_engine()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "hello-world.html" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
)

# not recognized as html
tera$render_to_string(
  "hello-world",
  x = "&world",
  y = "an apostrophe, '"
)
#> [1] "<p>Hello &world. This is an apostrophe, '.</p>"

# html
tera$render_to_string(
  "hello-world.html",
  x = "&world",
  y = "an apostrophe, '"
)
#> [1] "<p>Hello &amp;world. This is an apostrophe, &#x27;.</p>"

# turn off autoescape
tera$autoescape_off()
#> ✔ Autoescaping is now off!

tera$render_to_string(
  "hello-world.html",
  x = "&world",
  y = "an apostrophe, '"
)
#> [1] "<p>Hello &world. This is an apostrophe, '.</p>"
```
