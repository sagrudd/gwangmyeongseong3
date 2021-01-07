
#' @importFrom cli cli_alert_success
#' @export
LodestarDaemon <- R6::R6Class(
  "LodestarDaemon",
  public = list(
    initialize = function(daemon_port=8888, key=cyphr::key_openssl( openssl::aes_keygen())) {
      private$.daemon_port = as.integer(daemon_port)
      # start the daemon
      private$daemon_start(key)
      Sys.sleep(1.5)
      private$.con <- socketConnection(
        host = "localhost", port = private$.daemon_port, blocking = FALSE)
      private$set_key(key)

      coded <- convertRaw(cyphr::encrypt_string(.challenge_string, key))
      lodestar_creation_string <- stringr::str_interp(
        'lodestar <- gwangmyeongseong3::LodestarInstance$new(challenge="${coded}")\n')
      print(lodestar_creation_string)
      cat(lodestar_creation_string, file = private$.con)
      Sys.sleep(1.5)
      print(svSocket::evalServer(private$.con, 'ls()'))
      #svSocket::evalServer(private$.con, secret, coded)
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

    daemon_start = function(key) {
      cli::cli_h1("starting lodestar daemon")
      suppressWarnings(svSocket::startSocketServer(private$.daemon_port))
      cli::cli_alert_success(
        paste0(
          "daemon running on port [",
          private$.daemon_port,
          "] with key [",
          toString(key$key()),"]"))
      private$.is_running <- TRUE
    },


    set_key = function(key, file="key.rds") {
      cli::cli_alert(stringr::str_interp("saving one time key to [${file}]"))
      saveRDS(key2str(key), file)
    }

  )
)

