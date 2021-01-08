
#' @export
LodestarInstance <- R6::R6Class(
  "LodestarInstance",
  public = list(
    initialize = function(challenge, connection) {
      cli::cli_h1("creating lodestar instance")
      private$stop_signal <- FALSE
      private$challenge <- challenge
      private$connection <- connection
    },

    get_connection_count = function() {
      return(paste(private$connection_count,private$failed_conn_count, sep="/"))
    },

    get_sid_count = function() {
      return(length(private$.unique_hosts))
    },

    stop_request_received = function() {
      return(private$stop_signal)
    },

    validate_key = function(key, sid) {

      if (!sid %in% private$.unique_hosts) {
        private$.unique_hosts <- append(private$.unique_hosts, sid)
      }

      if (authenticate_key(key=key, encrypted=private$challenge)) {
        private$connection_count <- private$connection_count + 1
        return(private$connection)
      }
      private$failed_conn_count <- private$failed_conn_count + 1
      return(NA)
    }


  ),

  active = list(

  ),

  private = list(
    challenge = NA,
    connection = NA,
    key = NA,
    stop_signal = NA,
    sanity = NA,
    connection_count = 0,
    failed_conn_count = 0,
    .unique_hosts = list()
  )
)
