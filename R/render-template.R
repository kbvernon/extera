#' One-Off Template Rendering
#'
#' @description
#' For rendering a single template file, it may be preferable to use this
#' one-off rendering option.
#'
#' @param template_file character scalar, path to a template file
#' @param outfile character scalar, the path to file where template is to
#' be rendered.
#' @param ... specify context as key-value pairs where key is the template
#' variable and value is the data to inject.
#'
#' @return
#' outfile (invisibly)
#'
#' @details
#' Requires a path to a template file, not a template string.
#'
#' @export
#' @examples
#' outdir <- tempdir()
#'
#' template_file <- file.path(
#'   outdir,
#'   "hello-world-template.html"
#' )
#'
#' cat(
#'   '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   file = template_file
#' )
#'
#' outfile <- file.path(
#'   outdir,
#'   "hello-world-rendered.html"
#' )
#'
#' render_template_file(
#'   template_file,
#'   outfile,
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' readLines(outfile, warn = FALSE)
#'
render_template_file <- function(template_file, outfile, ...) {
  check_string(template_file)
  check_files_exist(template_file)
  check_string(outfile)

  context <- list(...)
  check_list_named(context)

  context_string <- yyjsonr::write_json_str(
    context,
    auto_unbox = TRUE
  )

  rendered_to_file <- .catch(
    rust_render_template(template_file, outfile, context_string)
  )

  check_bool(rendered_to_file)

  if (!rendered_to_file) {
    cli::cli_abort("Failed to render template to file.")
  }

  invisible(outfile)
}
