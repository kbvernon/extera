# List Templates In Library

List current templates in library.

## Usage

    $list_templates()

## Value

NULL (invisibly)

## Examples

``` r
tera <- new_engine()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "img-src" = '<img src="{{ img_src }}">'
)

tera$list_templates()
#> [1] "hello-world" "img-src"    
```
