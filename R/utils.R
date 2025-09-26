# catch an error condition returned by extendr
.catch <- function(cnd) {
  rlang::catch_cnd(
    {
      if (rlang::is_condition(cnd)) {
        cnd[["message"]] <- cnd[["value"]]
        rlang::cnd_signal(cnd)
      }
      cnd
    },
    "extendr_err"
  )

  cnd
}


# ensure a list contains only named elements
check_list_named <- function(dots, call = rlang::caller_call()) {
  if (!rlang::is_named2(dots)) {
    rlang::abort(
      "All arguments provided to {.arg ...} must be named",
      call = call
    )
  }

  invisible(dots)
}

# check if template files exist
check_files_exist <- function(files, call = rlang::caller_call()) {
  for (file in files) {
    if (!file.exists(file)) {
      cli::cli_abort("Could not find template at {.file file}.")
    }
  }

  invisible(files)
}
