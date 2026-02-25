# Add Templates From Strings

R6 method for `ExTera`: add templates to library from character strings.

    $add_string_templates(...)

## Arguments

- ...:

  specify list of templates as key-value pairs where key is the name of
  the template and value is a string template.

## Value

Self (invisibly)

## Details

All templates must be named.

## Examples

``` r
tera <- new_engine()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "img-src" = '<img src="{{ img_src }}">'
)

tera
#> ── ExTera ──
#> Template library:
#> • hello-world
#> • img-src
```
