# extera: Template Engine Inspired by 'tera'

The 'extera' package uses 'extendr' to provide access to the 'tera'
templating engine in Rust. Users mainly interact with an ExTera R6
object, which serves as a template library with encapsulated methods for
rendering templates. To render a template, users supply a dataset known
as a context, which consists of variable names and values. Template
syntax supports additional logic, including built-in filters, tests, and
functions, as well as loops, conditions, and inheritance. Documentation
for tera's templating syntax can be found at
<https://keats.github.io/tera/docs/>.

## Author

**Maintainer**: Kenneth Blake Vernon <kenneth.b.vernon@gmail.com>
([ORCID](https://orcid.org/0000-0003-0098-5092)) \[copyright holder\]
