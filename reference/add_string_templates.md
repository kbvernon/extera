# Add String Templates

Use `$add_string_templates()` to add templates to library from character
strings.

## Usage

``` r
add_string_templates(...)
```

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
tera <- ExTera$new()

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
