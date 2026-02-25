# Initialize ExTera

Use `Extera$new()` to create a new `ExTera` object. Will populate
template library with files in `dir` if specified.

## Usage

``` r
new(dir = NULL)
```

## Arguments

- dir:

  character scalar, a glob pattern with `*` wildcards indicating a
  potentially nested directory containing multiple file templates. If
  `NULL` (the default), an `ExTera` with an empty library is
  initialized. See details for more information.

## Value

Self (invisibly)

## Details

The glob pattern `templates/*.html` will match all files with the .html
extension located directly inside the `templates` folder, while the glob
pattern `templates/**/*.html` will match all files with the .html
extension directly inside or in a subdirectory of `templates`. The
default naming convention is to give each template their full relative
path from `templates` or whatever the directory is called.

## Examples

``` r
# initialize ExTera with empty library
tera <- ExTera$new()
tera
#> ── ExTera ──
#> Template library:

# initialize ExTera from directory with glob
template_dir <- file.path(tempdir(), "templates")

dir.create(template_dir)

tmp <- file.path(
  template_dir,
  "hello-world-template.html"
)

writeLines(
  text = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  con = tmp
)

tera <- ExTera$new(dir = file.path(template_dir, "*.html"))
tera
#> ── ExTera ──
#> Template library:
#> • hello-world-template.html
```
