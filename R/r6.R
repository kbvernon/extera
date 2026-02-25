#' @noRd
#' @export
ExTera <- R6::R6Class(
  "ExTera",
  public = list(
    initialize = function(dir = NULL) {
      check_string(dir, allow_null = TRUE)

      if (rlang::is_null(dir)) {
        private$extendr <- .catch(RustExTera$default())
      } else {
        private$extendr <- .catch(RustExTera$new(dir))
      }

      invisible(self)
    },

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

    add_file_templates = function(...) {
      templates <- rlang::list2(...)
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

    add_string_templates = function(...) {
      templates <- rlang::list2(...)
      check_list_named(templates)

      added_templates <- .catch(
        private$extendr$add_string_templates(templates)
      )

      if (!added_templates) {
        cli::cli_abort("Failed to add templates to engine.")
      }

      invisible(self)
    },

    list_templates = function() {
      .catch(private$extendr$list_templates())
    },

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

      context <- rlang::list2(...)
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

    render_to_string = function(template, ...) {
      check_string(template)

      template_library <- .catch(private$extendr$list_templates())

      if (!template %in% template_library) {
        cli::cli_abort(c(
          "Template not found.",
          "i" = "See `self$list_templates()` for available templates."
        ))
      }

      context <- rlang::list2(...)
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

    autoescape_on = function() {
      .catch(private$extendr$autoescape_on())
      cli::cli_alert_success("Autoescaping is now on!")
      invisible(self)
    },

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

#' @name new
#' @title Initialize ExTera
#' @usage new(dir = NULL)
#' @description
#' Use `Extera$new()` to create a new `ExTera` object. Will populate template
#' library with files in `dir` if specified.
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
#' @examples
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
NULL

#' @name print
#' @title Print an ExTera Object
#' @usage print(n = 10L, ...)
#' @description
#' Print method for `ExTera` object.
#' @param n integer scalar, number of templates to print (default is 10L)
#' @param ... ignored
#' @return
#' Self (invisibly)
#' @examples
#' tera <- ExTera$new()
#' tera
NULL

#' @name add_file_templates
#' @title Add File Templates
#' @usage add_file_templates(...)
#' @description
#' Use `$add_file_templates()` to add templates to library from file paths.
#' @param ... specify list of templates as key-value pairs where key is the
#' name of the template and value is the path to the template on file.
#' @details
#' All templates must be named.
#' @return
#' Self (invisibly)
#' @examples
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
NULL

#' @name add_string_templates
#' @title Add String Templates
#' @usage add_string_templates(...)
#' @description
#' Use `$add_string_templates()` to add templates to library from character
#' strings.
#' @param ... specify list of templates as key-value pairs where key is the
#' name of the template and value is a string template.
#' @details
#' All templates must be named.
#' @return
#' Self (invisibly)
#' @examples
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   "img-src" = '<img src="{{ img_src }}">'
#' )
#'
#' tera
NULL

#' @name list_templates
#' @title List Templates
#' @usage list_templates()
#' @description
#' Use `$list_templates()` to list current templates in library.
#' @return
#' character vector of template names.
#' @examples
#' tera <- ExTera$new()
#'
#' tera$add_string_templates(
#'   "hello-world" = '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   "img-src" = '<img src="{{ img_src }}">'
#' )
#'
#' tera$list_templates()
NULL

#' @name render
#' @title Render Template to File
#' @usage render(template, outfile, ...)
#' @description
#' Use `$render()` to render specified template to file.
#' @param template character scalar, the name of the template to render.
#' @param outfile character scalar, the path to file where template is to
#' be rendered.
#' @param ... specify context as key-value pairs where key is the template
#' variable and value is the data to inject.
#' @details
#' All context elements must be named.
#' @return
#' `outfile` (invisibly)
#' @examples
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
NULL

#' @name render_to_string
#' @title Render Template to String
#' @usage render_to_string(template, ...)
#' @description
#' Use `$render_to_string()` to render specified template to string.
#' @param template character scalar, the name of the template to render.
#' @param ... specify context as key-value pairs where key is the template
#' variable and value is the data to inject.
#' @details
#' All context elements must be named.
#' @return
#' Rendered string.
#' @examples
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
NULL

#' @name autoescape_on
#' @title Turn On Autoescaping
#' @usage autoescape_on()
#' @description
#' Use `$autoescape_on()` to turn on autoescaping of HTML. Autoescaping is on by
#' default.
#' @details
#' Autoescaping only applies to templates whose names end with `.html`,
#' `.htm`, or `.xml`.
#' @return
#' Self (invisibly)
#' @examples
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
NULL

#' @name autoescape_off
#' @title Turn Off Autoescaping
#' @usage autoescape_off()
#' @description
#' Use `$autoescape_off()` to turn off autoescaping of HTML.
#' @details
#' Autoescaping is on by default.
#' @return
#' Self (invisibly)
#' @examples
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
NULL
