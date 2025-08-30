# catch an error condition returned by extendr
.catch <- function(cnd) {
  catch_cnd(
    {
      if (is_condition(cnd)) {
        cnd[["message"]] <- cnd[["value"]]
        cnd_signal(cnd)
      }
      cnd
    },
    "extendr_err"
  )

  cnd
}


# ensure a list contains only named elements
check_list_named <- function(dots, call = caller_call()) {
  if (!is_named2(dots)) {
    abort(
      "All arguments provided to {.arg ...} must be named",
      call = call
    )
  }

  invisible(dots)
}

# check if template files exist
check_files_exist <- function(files, call = caller_call()) {
  for (file in files) {
    if (!file.exists(file)) {
      cli::cli_abort("Could not find template at {.file file}.")
    }
  }

  invisible(files)
}
