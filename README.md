

<!-- README.md is generated from README.qmd. Please edit that file -->

# extera

<!-- badges: start -->

[![R-CMD-check](https://github.com/kbvernon/extera/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kbvernon/extera/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/extera.png)](https://CRAN.R-project.org/package=extera)
[![extendr](https://img.shields.io/badge/extendr-%5E0.8.0-276DC2)](https://extendr.github.io/extendr/extendr_api/)
<!-- badges: end -->

The name `extera` is a portmandeau of `extendr` and `tera`, making it
suggestive of the package’s intended purpose, which is to provide an
[`extendr`](https://github.com/extendr/extendr)-powered R wrapper around
the blazing fast [`tera`](https://github.com/Keats/tera)
templating-engine in Rust.

## Installation

You can install the development version of extera like so:

``` r
# install.packages("pak")
pak::pak("kbvernon/extera")
```

## Example

Everything in `extera` revolves around the `ExTera` object.

``` r
library(extera)

tera <- ExTera$new()

tera$add_string_templates(
  "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  "star-wars" = '<h2>{{ title }}</h2>
<ol>
{%- for person in people %}
  {%- if person.films is containing("A New Hope") %}
  {%- if person.species and person.species is containing("Human") %}
  <li>{{ person.name }} ({{ person.homeworld }})</li>
  {%- endif %}
  {%- endif %}
{%- endfor %}
</ol>
'
)

tera
#> 
#> ── ExTera ──
#> 
#> Template library:
#> • star-wars
#> • hello-world

starwars <- dplyr::starwars[c("name", "films", "homeworld", "species")]

tera$render_to_string(
  "star-wars",
  title = "Humans of A New Hope",
  people = starwars
)
#> Rendered star-wars template:
#> 
#> <h2>Humans of A New Hope</h2>
#> <ol>
#>   <li>Luke Skywalker (Tatooine)</li>
#>   <li>Darth Vader (Tatooine)</li>
#>   <li>Leia Organa (Alderaan)</li>
#>   <li>Owen Lars (Tatooine)</li>
#>   <li>Beru Whitesun Lars (Tatooine)</li>
#>   <li>Biggs Darklighter (Tatooine)</li>
#>   <li>Obi-Wan Kenobi (Stewjon)</li>
#>   <li>Wilhuff Tarkin (Eriadu)</li>
#>   <li>Han Solo (Corellia)</li>
#>   <li>Wedge Antilles (Corellia)</li>
#>   <li>Raymus Antilles (Alderaan)</li>
#> </ol>
#> 
```
