#' Tera Templating Engine
#'
#' @description
#' `ExTera` is an R6 class object that uses extendr to encapsulate Tera's
#' templating engine. In addition to providing rendering functionality, it acts
#' as a library to hold templates that may include complex dependencies, a
#' feature called template "inheritance" in Tera.
#'
#' @details
#' A templating engine requires two things:
#' - a `template`, as you may have guessed, that includes variables and
#' rendering logic describing where and how to inject data, and
#' - a `context`, or a set of variables and values to be injected into the
#' template.
#'
#' Templating syntax is described in the [Tera docs](https://keats.github.io/tera/docs).
#'
#' @export
#' @examples
#' ## ------------------------------------------------
#' ## Method `ExTera$new()`
#' ## ------------------------------------------------
#'
#' # initialize ExTera with empty library
#' tera <- ExTera$new()
#' tera
#'
#' # initialize ExTera from directory with glob
#' template_dir <- file.path(tempdir(), "templates")
#'
#' dir.create(template_dir)
#'
#' tmp <- file.path(
#'   template_dir,
#'   "hello-world-template.html"
#' )
#'
#' writeLines(
#'   text = '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   con = tmp
#' )
#'
#' tera <- ExTera$new(dir = file.path(template_dir, "*.html"))
#' tera
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$add_file_templates()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' writeLines(
#'   '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   con = file.path(tempdir(), "hello-world.html")
#' )
#'
#' writeLines(
#'   '<img src="{{ img_src }}">',
#'   con = file.path(tempdir(), "img-src.html")
#' )
#'
#' tera$add_file_templates(
#'   "hello-world" = file.path(tempdir(), "hello-world.html"),
#'   "img-src" = file.path(tempdir(), "img-src.html")
#' )
#'
#' tera
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$add_string_templates()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   "img-src" = '<img src="{{ img_src }}">'
#' )
#'
#' tera
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$list_templates()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   "img-src" = '<img src="{{ img_src }}">'
#' )
#'
#' tera$list_templates()
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$render()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
#' )
#'
#' outfile <- file.path(tempdir(), "rendered-hello-world.html")
#'
#' tera$render(
#'   "hello-world",
#'   outfile = outfile,
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' readLines(outfile, warn = FALSE)
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$render_to_string()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
#' )
#'
#' tera$render_to_string(
#'   "hello-world",
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$autoescape_on()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   "hello-world.html" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
#' )
#'
#' # not recognized as html
#' tera$render_to_string(
#'   "hello-world",
#'   x = "&world",
#'   y = "an apostrophe, '"
#' )
#'
#' # html
#' tera$render_to_string(
#'   "hello-world.html",
#'   x = "&world",
#'   y = "an apostrophe, '"
#' )
#'
#' ## ------------------------------------------------
#' ## Method `ExTera$autoescape_off()`
#' ## ------------------------------------------------
#'
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world.html" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
#' )
#'
#' tera$autoescape_off()
#'
#' tera$render_to_string(
#'   "hello-world.html",
#'   x = "&world",
#'   y = "an apostrophe, '"
#' )

ExTera <- R6::R6Class(
  "ExTera",
  public = list(
    #' @description
    #' Create a new `ExTera` object. Will populate template library with files
    #' in `dir` if specified.
    #' @param dir character scalar, a glob pattern with `*` wildcards indicating
    #' a potentially nested directory containing multiple file templates. If
    #' `NULL` (the default), an `ExTera` with an empty library is initialized.
    #' See details for more information.
    #' @details
    #' The glob pattern `templates/*.html` will match all files with the
    #' .html extension located directly inside the `templates` folder, while the
    #' glob pattern `templates/**/*.html` will match all files with the .html
    #' extension directly inside or in a subdirectory of `templates`. The
    #' default naming convention is to give each template their full relative
    #' path from `templates` or whatever the directory is called.
    #' @return
    #' Self (invisibly)
    initialize = function(dir = NULL) {
      check_string(dir, allow_null = TRUE)

      if (is.null(dir)) {
        private$extendr <- .catch(RustExTera$default())
      } else {
        private$extendr <- .catch(RustExTera$new(dir))
      }

      invisible(self)
    },

    #' @description
    #' print method for `ExTera` object.
    #' @param n integer scalar, number of templates to print (default is 10L)
    #' @param ... ignored
    #' @return
    #' Self (invisibly)
    print = function(n = 10L, ...) {
      check_number_whole(n)

      template_library <- .catch(private$extendr$list_templates())
      template_library <- sort(template_library)

      if (length(template_library) > n) {
        overflow <- sprintf(
          "... (%s additional templates)",
          length(template_library) - n
        )

        template_library <- c(template_library[seq_len(n)], overflow)
      }

      remove_vertical_space <- list(
        h2 = list("margin-top" = 0, "margin-bottom" = 0)
      )

      cli::cli_div(theme = remove_vertical_space)
      cli::cli_h2("ExTera")
      cli::cli_text("Template library:")
      cli::cli_ul(template_library)
      cli::cli_end()

      invisible(self)
    },

    #' @description
    #' Add templates to library from file paths.
    #' @param ... specify list of templates as key-value pairs where key is the
    #' name of the template and value is the path to the template on file.
    #' @details
    #' All templates must be named.
    #' @return
    #' Self (invisibly)
    add_file_templates = function(...) {
      templates <- list2(...)
      check_list_named(templates)
      check_files_exist(templates)

      added_templates <- .catch(
        private$extendr$add_file_templates(templates)
      )

      if (!added_templates) {
        cli::cli_abort("Failed to add templates to engine.")
      }

      invisible(self)
    },

    #' @description
    #' Add templates to library from character strings.
    #' @param ... specify list of templates as key-value pairs where key is the
    #' name of the template and value is a string template.
    #' @details
    #' All templates must be named.
    #' @return
    #' Self (invisibly)
    add_string_templates = function(...) {
      templates <- list2(...)
      check_list_named(templates)

      added_templates <- .catch(
        private$extendr$add_string_templates(templates)
      )

      if (!added_templates) {
        cli::cli_abort("Failed to add templates to engine.")
      }

      invisible(self)
    },

    #' @description
    #' List current templates in library.
    #' @return
    #' NULL (invisibly)
    list_templates = function() {
      .catch(private$extendr$list_templates())
    },

    #' @description
    #' Render specified template to file.
    #' @param template character scalar, the name of the template to render.
    #' @param outfile character scalar, the path to file where template is to
    #' be rendered.
    #' @param ... specify context as key-value pairs where key is the template
    #' variable and value is the data to inject.
    #' @details
    #' All context elements must be named.
    #' @return
    #' outfile (invisibly)
    render = function(template, outfile, ...) {
      check_string(template)
      check_string(outfile)

      template_library <- .catch(private$extendr$list_templates())

      if (!template %in% template_library) {
        cli::cli_abort(c(
          "Template not found.",
          "i" = "See `self$list_templates()` for available templates."
        ))
      }

      context <- list2(...)
      check_list_named(context)

      context_string <- yyjsonr::write_json_str(
        context,
        auto_unbox = TRUE
      )

      rendered_to_file <- .catch(
        private$extendr$render_to_file(
          template,
          context_string,
          outfile
        )
      )

      check_bool(rendered_to_file)

      if (!rendered_to_file) {
        cli::cli_abort("Failed to render template to file.")
      }

      invisible(outfile)
    },

    #' @description
    #' Render specified template to string.
    #' @param template character scalar, the name of the template to render.
    #' @param ... specify context as key-value pairs where key is the template
    #' variable and value is the data to inject.
    #' @details
    #' All context elements must be named.
    #' @return
    #' Rendered string with class `TeraString` for "pretty" printing.
    render_to_string = function(template, ...) {
      check_string(template)

      template_library <- .catch(private$extendr$list_templates())

      if (!template %in% template_library) {
        cli::cli_abort(c(
          "Template not found.",
          "i" = "See `self$list_templates()` for available templates."
        ))
      }

      context <- list2(...)
      check_list_named(context)

      context_string <- yyjsonr::write_json_str(
        context,
        auto_unbox = TRUE
      )

      rendered_string <- .catch(
        private$extendr$render_to_string(
          template,
          context_string
        )
      )

      check_string(rendered_string)

      if (rendered_string == "") {
        cli::cli_warn("Rendering returned an empty string.")
      }

      rendered_string
    },

    #' @description
    #' Turn on autoescaping of HTML. Autoescaping is on by default.
    #' @details
    #' Autoescaping only applies to templates whose names end with ".html",
    #' ".htm", or ".xml".
    #' @return
    #' Self (invisibly)
    autoescape_on = function() {
      .catch(private$extendr$autoescape_on())
      cli::cli_alert_success("Autoescaping is now on!")
      invisible(self)
    },

    #' @description
    #' Turn off autoescaping of HTML.
    #' @details
    #' Autoescaping is on by default.
    #' @return
    #' Self (invisibly)
    autoescape_off = function() {
      .catch(private$extendr$autoescape_off())
      cli::cli_alert_success("Autoescaping is now off!")
      invisible(self)
    }
  ),
  private = list(
    extendr = NA
  ),
  cloneable = FALSE
)
