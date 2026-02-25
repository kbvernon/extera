# List Templates

Use `$list_templates()` to list current templates in library.

## Usage

``` r
list_templates()
```

## Value

character vector of template names.

## Examples

``` r
tera <- ExTera$new()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "img-src" = '<img src="{{ img_src }}">'
)

tera$list_templates()
#> [1] "hello-world" "img-src"    
```
