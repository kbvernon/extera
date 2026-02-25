# Print ExTera

R6 method for `ExTera`: print `ExTera` object.

    $print(n = 10L, ...)

## Arguments

- n:

  integer scalar, number of templates to print (default is 10L)

- ...:

  ignored

## Value

Self (invisibly)

## Examples

``` r
tera <- new_engine()

# call it directly
tera$print()
#> ── ExTera ──
#> Template library:

# or just let R handle it
tera
#> ── ExTera ──
#> Template library:
```
