#' One-Off Template Rendering
#'
#' @description
#' For rendering a single template file, it may be preferable to use this
#' one-off rendering option.
#'
#' @param path character scalar, path to a template file
#' @param outfile character scalar, the path to file where template is to
#' be rendered. If `NULL` (the default), it will render the template file to a
#' string in the current R session.
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
#' tmp <- file.path(
#'   outdir,
#'   "hello-world-template.html"
#' )
#'
#' writeLines(
#'   '<p>Hello {{ x }}. This is {{ y }}.</p>',
#'   con = tmp
#' )
#'
#' outfile <- file.path(
#'   outdir,
#'   "hello-world-rendered.html"
#' )
#'
#' # render to string
#' render_template(
#'   tmp,
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' # render to file
#' render_template(
#'   tmp,
#'   outfile = outfile,
#'   x = "world",
#'   y = "ExTera"
#' )
#'
#' readLines(outfile, warn = FALSE)

render_template <- function(path, outfile = NULL, ...) {
  check_string(path)
  check_files_exist(path)
  check_string(outfile, allow_null = TRUE)

  tera <- ExTera$new()

  template_name <- basename(path)

  tera$add_file_templates(!!template_name := path)

  if (is.null(outfile)) {
    return(tera$render_to_string(template_name, ...))
  } else {
    return(tera$render(template_name, outfile = outfile, ...))
  }
}
