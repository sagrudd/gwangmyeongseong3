
#' @importFrom cli cli_alert_success
LodestarDaemon <- R6::R6Class(
  "LodestarDaemon",
  public = list(
    initialize = function(daemon_port=8888) {
      private$.daemon_port = as.integer(daemon_port)
      private$.daemon_key = "mykey"
      # start the daemon
      private$daemon_start()
      private$.con <- socketConnection(
        host = "localhost", port = private$.daemon_port, blocking = FALSE)
      #svSocket::evalServer(private$.con, 'lodestar <- gwangmyeongseong3::LodestarInstance$new()')

      lodestar_creation_string = sprintf("lodestar <- gwangmyeongseong3::LodestarInstance$new()\n")

      cat(lodestar_creation_string, file = private$.con)
    },


    daemon_stop = function(e) {
      if (private$.is_running) {
        cli::cli_h1("stopping lodestar daemon")
        suppressWarnings(svSocket::stopSocketServer(private$.daemon_port))
        cli::cli_alert_success("Goodbye")
        private$.is_running <- FALSE
      }
    },

    daemon_status = function() {
      return(
        paste0(
          "[",svSocket::evalServer(private$.con, 'lodestar$get_connection_count()'),
          "] connections from [12] hosts."))
    },

    is_running = function() {
      return(TRUE)
        # private$.is_running &
        #   !svSocket::evalServer(private$.con, 'lodestar$stop_request_received()'))
    }

  ),

  private = list(
    .is_running = NA,
    .daemon_port = NA,
    .daemon_key = NA,
    .con = NA,

    daemon_start = function() {
      cli::cli_h1("starting lodestar daemon")
      suppressWarnings(svSocket::startSocketServer(private$.daemon_port))
      cli::cli_alert_success(
        paste0(
          "daemon running on port [",
          private$.daemon_port,
          "] with key [",
          private$.daemon_key,"]"))
      private$.is_running <- TRUE
    }

  )
)

