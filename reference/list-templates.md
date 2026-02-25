# List Templates In Library

R6 method for `ExTera`: list current templates in library.

    $list_templates()

## Value

a `character` vector of template names

## Examples

``` r
tera <- new_engine()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "img-src" = '<img src="{{ img_src }}">'
)

tera$list_templates()
#> [1] "img-src"     "hello-world"
```
