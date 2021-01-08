
#' @importFrom cli cli_alert_success
#' @export
LodestarDaemon <- R6::R6Class(
  "LodestarDaemon",
  public = list(
    initialize = function(lodestar_conn, daemon_port=8888, daemon_host="localhost", key=cyphr::key_openssl( openssl::aes_keygen())) {
      private$.daemon_port = as.integer(daemon_port)
      # start the daemon
      private$daemon_start(key)
      Sys.sleep(1.5)
      private$.con <- socketConnection(
        host = "localhost", port = private$.daemon_port, blocking = FALSE)
      private$set_key(daemon_host, key)

      coded <- convertRaw(cyphr::encrypt_string(.challenge_string, key))
      connection <- convertRaw(cyphr::encrypt_object(lodestar_conn$as_list(), key))
      lodestar_creation_string <- stringr::str_interp(
        'lodestar <- gwangmyeongseong3::LodestarInstance$new(challenge="${coded}", connection="${connection}")\n')
      cat(lodestar_creation_string, file = private$.con)
      Sys.sleep(1.5)
      #print(svSocket::evalServer(private$.con, 'ls()'))
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
          "] connections from [",svSocket::evalServer(private$.con, 'lodestar$get_sid_count()'),"] process(es)."))
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


    set_key = function(host, key, file="key.rds") {
      v <- c(host, private$.daemon_port, key2str(key))
      cli::cli_alert(stringr::str_interp("saving one time key to [${file}]"))
      saveRDS(v, file)
    }

  )
)

