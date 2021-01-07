
#' @export
LodestarInstance <- R6::R6Class(
  "LodestarInstance",
  public = list(
    initialize = function(challenge) {
      cli::cli_h1("creating lodestar instance")
      private$stop_signal <- FALSE
      private$challenge <- challenge
    },

    get_connection_count = function() {
      return(paste(private$connection_count,private$failed_conn_count, sep="/"))
    },

    stop_request_received = function() {
      return(private$stop_signal)
    },

    validate_key = function(key) {
      mystring = cyphr::decrypt_string(
        gwangmyeongseong3:::convertSHex(private$challenge),
        gwangmyeongseong3:::str2key(key))
      if (mystring == .challenge_string) {
        private$connection_count <- private$connection_count + 1
      } else {
        private$failed_conn_count <- private$failed_conn_count + 1
      }
      return(private$connection_count)
    }


  ),

  active = list(

  ),

  private = list(
    challenge = NA,
    key = NA,
    stop_signal = NA,
    sanity = NA,
    connection_count = 0,
    failed_count = 0,
    failed_conn_count = 0
  )
)
