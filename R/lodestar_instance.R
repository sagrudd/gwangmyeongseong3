
#' @export
LodestarInstance <- R6::R6Class(
  "LodestarDaemon",
  public = list(
    initialize = function() {
      cli::cli_h1("creating lodestar instance")
      private$stop_signal <- FALSE
    },

    get_connection_count = function() {
      return(private$connection_count)
    },

    stop_request_received = function() {
      return(private$stop_signal)
    },

    validate_key = function(key) {
      private$connection_count <- private$connection_count + 1
    }
  ),

  private = list(
    stop_signal = NA,
    connection_count = 0
  )
)
