

<!-- README.md is generated from README.qmd. Please edit that file -->

# extera

<!-- badges: start -->

[![R-CMD-check](https://github.com/kbvernon/extera/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kbvernon/extera/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/extera.png)](https://CRAN.R-project.org/package=extera)
[![extendr](https://img.shields.io/badge/extendr-%5E0.8.0-276DC2)](https://extendr.github.io/extendr/extendr_api/)
<!-- badges: end -->

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
#> 
#> ── ExTera ──
#> 
#> Template library:
#> • hello-world

tera$render_to_string(
  "hello-world",
  x = "world",
  y = "ExTera"
)
#> Rendered hello-world template:
#> 
#> <p>Hello world. This is ExTera.</p>
#> 
```

The syntax and API should look pretty familiar to anyone who has used
`glue` to do something like `glue::glue("Foo { x }", x = "bar")`. The
big difference is the object-oriented workflow.

## Initializing `ExTera`

Everything in `extera` revolves around the `ExTera` object, which serves
as a template library with encapsulated rendering methods. In the above
example, we initialize an `ExTera` with an empty template library by
calling `ExTera$new()` with no arguments.

If you have a complicated directory system with nested templates and
inheritance patterns - a common situation for web development, you may
find it easier to initialize an `ExTera` by specifying the directory
with a glob containing the `*` wildcard to indicate any number of
subfolders and template files. Suppose, for example, that you have a
`website` directory that looks like this:

<details class="code-fold">
<summary>Code</summary>

``` r
website <- file.path(tempdir(), "website")

dir.create(website)
dir.create(file.path(website, "posts"))

writeLines(
  text = '<p>Hello {{ x }}. This is {{ y }}.</p>',
  con = file.path(website, "index.html")
)

writeLines(
  text = "<h2>About Me</h2><p>{{ description }}</p>",
  con = file.path(website, "about-me.html")
)

writeLines(
  text = '<body>
  <h2>{{ title }}</h2>
  <p>{{ paragraph }}</p>
</body>
',
  con = file.path(website, "posts", "blog-template.html")
)

cat(
  "website",
  list.files(website, recursive = TRUE),
  sep = "\n- "
)
```

</details>

    website
    - about-me.html
    - index.html
    - posts/blog-template.html

You can generate a new `ExTera` around this directory like so

``` r
tera <- ExTera$new(dir = file.path(website, "**/*.html"))

tera
#> 
#> ── ExTera ──
#> 
#> Template library:
#> • about-me.html
#> • index.html
#> • posts/blog-template.html
```

## Rendering basics

To render a template, you have to supply a `context`, or a set of
key-value pairs, with the keys being the variable names - surrounded by
`{{ variable }}` in the template - and their values being the content to
inject into the template. You can render a template in one of two ways,
using

- `self$render()` to render to a file on disk or
- `self$render_to_string()` to render to a character string in the
  current R session.

Consider our hypothetical website’s blog post template:

<details class="code-fold">
<summary>Code</summary>

``` r
file.path(website, "posts", "blog-template.html") |>
  readLines() |>
  cat(sep = "\n")
```

</details>

    <body>
      <h2>{{ title }}</h2>
      <p>{{ paragraph }}</p>
    </body>

Here are the two ways to render this template.

``` r
# render to file
outfile <- file.path(tempdir(), "rendered-blog-post.html")

tera$render(
  "posts/blog-template.html",
  outfile = outfile,
  title = "This is my blog",
  paragraph = "Democracy was fun, wasn't it?"
)

cat(
  readLines(outfile, warn = FALSE),
  sep = "\n"
)
#> <body>
#>   <h2>This is my blog</h2>
#>   <p>Democracy was fun, wasn&#x27;t it?</p>
#> </body>

# render to string
tera$render_to_string(
  "posts/blog-template.html",
  title = "This is my blog",
  paragraph = "Democracy was fun, wasn't it?"
)
#> Rendered posts/blog-template.html template:
#> 
#> <body>
#>   <h2>This is my blog</h2>
#>   <p>Democracy was fun, wasn&#x27;t it?</p>
#> </body>
#> 
#> 
```

Did you notice that the apostrophe was converted into the html character
entity `&#x27;`? This is an example of escaping, which `tera` does by
default. You can turn off this behavior using `self$autoescape_off()`.

``` r
tera$autoescape_off()

tera$render_to_string(
  "posts/blog-template.html",
  title = "This is my blog",
  paragraph = "Democracy was fun, wasn't it?"
)
#> Rendered posts/blog-template.html template:
#> 
#> <body>
#>   <h2>This is my blog</h2>
#>   <p>Democracy was fun, wasn't it?</p>
#> </body>
#> 
#> 
```

And then turn it back on with `self$autoescape_on()`.

## Rendering logic

The `tera` templating engine offers a lot of additional functionality,
like control flow and data manipulation. The following example shows how
to construct a for-loop, add conditional statements, and apply built-in
functions. Notice that `{% expression %}` is used to signal these
expressions in the template. The use of dashes tells the renderer to
remove white space before (`{%- expression %}`) or after
(`{% expression -%}`) the expression.

``` r
tera$add_string_templates(
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

## Context format

In that for-loop, you may have noticed that we used dot-indexing syntax,
e.g., `person.name`. If `person` was a list in R, this would be
equivalent to `person[["name"]]`. This usage suggests that the context
should have a specific format, like a named list. In fact, the `tera`
templating engine generally expects data to be in, let’s say, a
JSON-like format. The biggest way this affects data structures coming
from R is in the way that data.frames are handled. In R, tables are
column-major, but the JSON-like format that `tera` wants is row-major or
“record” oriented.

The way `extera` handles this is by serializing all R data structures
added to the context as JSON using `yyjsonr`. This is not ideal, but it
is relatively safe. It also enforces a specific data model that users
should be able to reason about fairly well. Oh, and `yyjsonr` is very,
very fast, so performance issues are minor.

It may help to see an example of what that looks like. This applies the
same filters we used in our template above.

``` r
starwars[["in_a_new_hope"]] <- sapply(
  starwars[["films"]],
  \(x) "A New Hope" %in% x
)

starwars <- subset(
  starwars,
  in_a_new_hope & !is.na(species) & species == "Human",
  select = c(name, homeworld)
)

json_str <- yyjsonr::write_json_str(
  list(
    title = "Humans of A New Hope",
    people = starwars
  ),
  pretty = TRUE
)

cat(json_str)
#> {
#>   "title": [
#>     "Humans of A New Hope"
#>   ],
#>   "people": [
#>     {
#>       "name": "Luke Skywalker",
#>       "homeworld": "Tatooine"
#>     },
#>     {
#>       "name": "Darth Vader",
#>       "homeworld": "Tatooine"
#>     },
#>     {
#>       "name": "Leia Organa",
#>       "homeworld": "Alderaan"
#>     },
#>     {
#>       "name": "Owen Lars",
#>       "homeworld": "Tatooine"
#>     },
#>     {
#>       "name": "Beru Whitesun Lars",
#>       "homeworld": "Tatooine"
#>     },
#>     {
#>       "name": "Biggs Darklighter",
#>       "homeworld": "Tatooine"
#>     },
#>     {
#>       "name": "Obi-Wan Kenobi",
#>       "homeworld": "Stewjon"
#>     },
#>     {
#>       "name": "Wilhuff Tarkin",
#>       "homeworld": "Eriadu"
#>     },
#>     {
#>       "name": "Han Solo",
#>       "homeworld": "Corellia"
#>     },
#>     {
#>       "name": "Wedge Antilles",
#>       "homeworld": "Corellia"
#>     },
#>     {
#>       "name": "Raymus Antilles",
#>       "homeworld": "Alderaan"
#>     }
#>   ]
#> }
```

## Inheritance

Templates can inherit content from each other in one of two ways, either
using `include` or, for more complicated inheritance, `extends`.

``` r
tera$add_string_templates(
  "index.html" = '<p>Hello {{ x }}. This is {{ y }}.</p>
<div>
{% include "posts/blog-template.html" -%}
</div>
'
)

tera$render_to_string(
  "index.html",
  x = "world",
  y = "ExTera",
  title = "My blog post",
  paragraph = "The Book of Bokonon tells us..."
)
#> Rendered index.html template:
#> 
#> <p>Hello world. This is ExTera.</p>
#> <div>
#> <body>
#>   <h2>My blog post</h2>
#>   <p>The Book of Bokonon tells us...</p>
#> </body>
#> 
#> </div>
#> 
```

The extension mechanism is a little more involved, requiring that you
specify content blocks where content from a child document should be
injected. In the following example, we define a single block called
`content` in the base or parent template and specify what it includes in
the child template.

``` r
base_html <- '<body>
  <div id="content">
    {% block content %}
    {% endblock content %}
  </div>
</body>
'

child_html <- '{% extends "base.html" %}
{%- block content %}
  <h1>{{ title }}</h1>
  <p>{{ paragraph }}</p>
{% endblock content -%}
'

tera$add_string_templates(
  "base.html" = base_html,
  "child.html" = child_html
)

tera$render_to_string(
  "child.html",
  title = "Index",
  paragraph = "Welcome to my homepage."
)
#> Rendered child.html template:
#> 
#> <body>
#>   <div id="content">
#>     
#>   <h1>Index</h1>
#>   <p>Welcome to my homepage.</p>
#> 
#>   </div>
#> </body>
#> 
```

For more details, check out the
[documentation](https://keats.github.io/tera/docs/) for `tera`.
