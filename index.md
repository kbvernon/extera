# extera

The name `extera` is a portmanteau of `extendr` and `tera`, making it
suggestive of the package’s intended purpose, which is to provide an
[`extendr`](https://github.com/extendr/extendr)-powered R wrapper around
the blazing fast [`tera`](https://github.com/Keats/tera)
templating-engine in Rust.

## Installation

You can install the development version of `extera` like so:

``` r
# install.packages("pak")
pak::pak("kbvernon/extera")
```

## Usage

To get a feel for what `extera` can do, let’s start with a simple “hello
world” example.

``` r
library(extera)

tera <- ExTera$new()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
)

tera
#> ── ExTera ──
#> Template library:
#> • hello-world

tera$render_to_string(
  "hello-world",
  x = "world",
  y = "ExTera"
)
#> [1] "<p>Hello world. This is ExTera.</p>"
```

The syntax and API should look pretty familiar to anyone who has used
`glue` to do something like `glue::glue("Foo { x }", x = "bar")`. The
big difference is the object-oriented workflow. To learn more, check out
the [Getting
started](https://kbvernon.github.io/extera/articles/extera.html) article
on the package website, or call
[`vignette("extera")`](https://kbvernon.github.io/extera/articles/extera.md).
