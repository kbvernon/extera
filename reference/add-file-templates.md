# Add Templates From Paths

Add templates to library from file paths.

## Arguments

- ...:

  specify list of templates as key-value pairs where key is the name of
  the template and value is the path to the template on file.

## Value

Self (invisibly)

## Details

All templates must be named.

## Examples

``` r
tera <- new_engine()

writeLines(
  '<p>Hello {{ x }}. This is {{ y }}.</p>',
  con = file.path(tempdir(), "hello-world.html")
)

writeLines(
  '<img src="{{ img_src }}">',
  con = file.path(tempdir(), "img-src.html")
)

tera$add_file_templates(
  "hello-world" = file.path(tempdir(), "hello-world.html"),
  "img-src" = file.path(tempdir(), "img-src.html")
)

tera
#> ── ExTera ──
#> Template library:
#> • hello-world
#> • img-src
```
