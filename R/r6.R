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
#' tera <- ExTera$new()
#'
#' # from string template
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>'
#' )
#'
#' # to string render
#' tera$render_to_string(
#'   "hello-world",
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' # from file template
#' outdir <- tempdir()
#'
#' tmp <- file.path(
#'   outdir,
#'   "hello-world-template.html"
#' )
#'
#' cat(
#'   '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   file = tmp
#' )
#'
#' tera$add_file_templates(
#'   "hello-world.html" = tmp
#' )
#'
#' outfile <- file.path(
#'   outdir,
#'   "hello-world-rendered.html"
#' )
#'
#' # to file render
#' tera$render_to_file(
#'   "hello-world.html",
#'   outfile = outfile,
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' readLines(outfile, warn = FALSE)
#'
ExTera <- R6::R6Class(
  "ExTera",
  public = list(
    #' @description
    #' Create a new `ExTera` object.
    #' @return
    #' Self (invisibly)
    initialize = function() {
      private$extendr <- .catch(RustExTera$new())
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

      if (length(template_library) > n) {
        overflow <- sprintf(
          "... (%s additional templates)",
          length(template_library) - n
        )

        template_library <- c(template_library[seq_len(n)], overflow)
      }

      cli::cli_h2("ExTera")
      cli::cli_text("")
      cli::cli_text("Template library:")
      cli::cli_ul(template_library)

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
      invisible(NULL)
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
    render_to_file = function(template, outfile, ...) {
      check_string(template)
      check_string(outfile)

      template_library <- .catch(private$extendr$list_templates())

      if (!template %in% template_library) {
        cli::cli_abort(
          "Template not found.",
          "i" = "See `self$list_templates()` for available templates."
        )
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
        cli::cli_abort(
          "Template not found.",
          "i" = "See `self$list_templates()` for available templates."
        )
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

      class(rendered_string) <- c("TeraString", class(rendered_string))
      attr(rendered_string, "template") <- template

      rendered_string
    },

    #' @description
    #' Turn on autoescaping of HTML.
    #' @details
    #' Autoescaping is on by default.
    #' @return
    #' Self (invisibly)
    autoescape_on = function() {
      .catch(private$extendr$autoescape_on())
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
      invisible(self)
    }
  ),
  private = list(
    extendr = NA
  )
)

#' @export
#' @method print TeraString
print.TeraString <- function(x, ...) {
  cli::cli_text("Rendered { attr(x, 'template') } template:")
  cli::cli_text("")
  cli::cli_text("{ cat(x) }")
}
