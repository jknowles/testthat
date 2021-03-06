#' Run all of the tests in a directory.
#'
#' Test files start with \code{test} and are executed in alphabetical order
#' (but they shouldn't have dependencies). Helper files start with
#' \code{helper} and loaded before any tests are run.
#'
#' @param path path to tests
#' @param reporter reporter to use
#' @param filter If not \code{NULL}, only tests with file names matching this
#'   regular expression will be executed.  Matching will take on the file
#'   name after it has been stripped of \code{"test-"} and \code{".r"}.
#' @param env environment in which to execute test suite. Defaults to new
#    environment inheriting from the global environment.
#' @export
test_dir <- function(path, filter = NULL, reporter = "summary", env = NULL) {
  reporter <- find_reporter(reporter)
  if (is.null(env)) {
    env <- new.env(parent = globalenv())
  }

  source_dir(path, "^helper.*\\.[rR]$", env = env)

  files <- dir(path, "^test.*\\.[rR]$", full.names = TRUE)
  if (!is.null(filter)) {
    test_names <- basename(files)
    test_names <- str_replace(test_names, "test-?", "")
    test_names <- str_replace(test_names, "\\.[rR]", "")

    files <- files[str_detect(test_names, filter)]
  }
  with_reporter(reporter, lapply(files, function(file) {
    sys.source(file, chdir = TRUE, envir = new.env(parent = env))
    end_context()
  }))
}

#' Load all source files in a directory.
#'
#' The expectation is that the files can be sourced in alphabetical order.
#'
#' @param path path to tests
#' @param pattern regular expression used to filter files
#' @param env environment in which to execute test suite. Defaults to new
#    environment inheriting from the global environment.
#' @param chdir change working directory to path?
#' @keywords internal
#' @export
#' @usage source_dir(path, pattern="\\\\.[rR]$", env = NULL, chdir=TRUE)
source_dir <- function(path, pattern = "\\.[rR]$", env = NULL, chdir = TRUE) {
  files <- sort(dir(path, pattern, full.names = TRUE))
  if (is.null(env)) {
    env <- new.env(parent = globalenv())
  }

  lapply(files, sys.source, chdir = chdir, envir = env)
}

#' Run all tests in specified file.
#'
#' @param path path to file
#' @param reporter reporter to use
#' @export
test_file <- function(path, reporter = "summary") {
  reporter <- find_reporter(reporter)
  with_reporter(reporter, {
    sys.source(path, new.env(parent = globalenv()), chdir = TRUE)
    end_context()
  })
}
