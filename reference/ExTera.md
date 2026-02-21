# Tera Templating Engine

`ExTera` is an R6 class object that uses extendr to encapsulate Tera's
templating engine. In addition to providing rendering functionality, it
acts as a library to hold templates that may include complex
dependencies, a feature called template "inheritance" in Tera.

## Details

A templating engine requires two things:

- a `template`, as you may have guessed, that includes variables and
  rendering logic describing where and how to inject data, and

- a `context`, or a set of variables and values to be injected into the
  template.

Templating syntax is described in the [Tera
docs](https://keats.github.io/tera/docs).

## Methods

### Public methods

- [`ExTera$new()`](#method-ExTera-new)

- [`ExTera$print()`](#method-ExTera-print)

- [`ExTera$add_file_templates()`](#method-ExTera-add_file_templates)

- [`ExTera$add_string_templates()`](#method-ExTera-add_string_templates)

- [`ExTera$list_templates()`](#method-ExTera-list_templates)

- [`ExTera$render()`](#method-ExTera-render)

- [`ExTera$render_to_string()`](#method-ExTera-render_to_string)

- [`ExTera$autoescape_on()`](#method-ExTera-autoescape_on)

- [`ExTera$autoescape_off()`](#method-ExTera-autoescape_off)

------------------------------------------------------------------------

### Method `new()`

Create a new `ExTera` object. Will populate template library with files
in `dir` if specified.

#### Usage

    ExTera$new(dir = NULL)

#### Arguments

- `dir`:

  character scalar, a glob pattern with `*` wildcards indicating a
  potentially nested directory containing multiple file templates. If
  `NULL` (the default), an `ExTera` with an empty library is
  initialized. See details for more information.

#### Details

The glob pattern `templates/*.html` will match all files with the .html
extension located directly inside the `templates` folder, while the glob
pattern `templates/**/*.html` will match all files with the .html
extension directly inside or in a subdirectory of `templates`. The
default naming convention is to give each template their full relative
path from `templates` or whatever the directory is called.

#### Returns

Self (invisibly)

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

print method for `ExTera` object.

#### Usage

    ExTera$print(n = 10L, ...)

#### Arguments

- `n`:

  integer scalar, number of templates to print (default is 10L)

- `...`:

  ignored

#### Returns

Self (invisibly)

------------------------------------------------------------------------

### Method `add_file_templates()`

Add templates to library from file paths.

#### Usage

    ExTera$add_file_templates(...)

#### Arguments

- `...`:

  specify list of templates as key-value pairs where key is the name of
  the template and value is the path to the template on file.

#### Details

All templates must be named.

#### Returns

Self (invisibly)

------------------------------------------------------------------------

### Method `add_string_templates()`

Add templates to library from character strings.

#### Usage

    ExTera$add_string_templates(...)

#### Arguments

- `...`:

  specify list of templates as key-value pairs where key is the name of
  the template and value is a string template.

#### Details

All templates must be named.

#### Returns

Self (invisibly)

------------------------------------------------------------------------

### Method `list_templates()`

List current templates in library.

#### Usage

    ExTera$list_templates()

#### Returns

NULL (invisibly)

------------------------------------------------------------------------

### Method `render()`

Render specified template to file.

#### Usage

    ExTera$render(template, outfile, ...)

#### Arguments

- `template`:

  character scalar, the name of the template to render.

- `outfile`:

  character scalar, the path to file where template is to be rendered.

- `...`:

  specify context as key-value pairs where key is the template variable
  and value is the data to inject.

#### Details

All context elements must be named.

#### Returns

outfile (invisibly)

------------------------------------------------------------------------

### Method `render_to_string()`

Render specified template to string.

#### Usage

    ExTera$render_to_string(template, ...)

#### Arguments

- `template`:

  character scalar, the name of the template to render.

- `...`:

  specify context as key-value pairs where key is the template variable
  and value is the data to inject.

#### Details

All context elements must be named.

#### Returns

Rendered string with class `TeraString` for "pretty" printing.

------------------------------------------------------------------------

### Method `autoescape_on()`

Turn on autoescaping of HTML. Autoescaping is on by default.

#### Usage

    ExTera$autoescape_on()

#### Details

Autoescaping only applies to templates whose names end with ".html",
".htm", or ".xml".

#### Returns

Self (invisibly)

------------------------------------------------------------------------

### Method `autoescape_off()`

Turn off autoescaping of HTML.

#### Usage

    ExTera$autoescape_off()

#### Details

Autoescaping is on by default.

#### Returns

Self (invisibly)

## Examples

``` r
## ------------------------------------------------
## Method `ExTera$new()`
## ------------------------------------------------

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

## ------------------------------------------------
## Method `ExTera$add_file_templates()`
## ------------------------------------------------

tera <- ExTera$new()

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

## ------------------------------------------------
## Method `ExTera$add_string_templates()`
## ------------------------------------------------

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

## ------------------------------------------------
## Method `ExTera$list_templates()`
## ------------------------------------------------

tera <- ExTera$new()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "img-src" = '<img src="{{ img_src }}">'
)

tera$list_templates()
#> [1] "hello-world" "img-src"    

## ------------------------------------------------
## Method `ExTera$render()`
## ------------------------------------------------

tera <- ExTera$new()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
)

outfile <- file.path(tempdir(), "rendered-hello-world.html")

tera$render(
  "hello-world",
  outfile = outfile,
  x = "world",
  y = "ExTera"
)

readLines(outfile, warn = FALSE)
#> [1] "<p>Hello world. This is ExTera.</p>"

## ------------------------------------------------
## Method `ExTera$render_to_string()`
## ------------------------------------------------

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

## ------------------------------------------------
## Method `ExTera$autoescape_on()`
## ------------------------------------------------

tera <- ExTera$new()

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

## ------------------------------------------------
## Method `ExTera$autoescape_off()`
## ------------------------------------------------

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
