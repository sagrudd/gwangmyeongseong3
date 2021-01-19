
#' @importFrom cli cli_alert_success
#' @export
LodestarDaemon <- R6::R6Class(
  "LodestarDaemon",
  public = list(
    initialize = function(lodestar_conn, directory="./", key=cyphr::key_openssl( openssl::aes_keygen())) {
      private$.lstar <- lodestar_conn
      private$.directory <- directory
      private$set_key(key)

      private$.challenge <- convertRaw(cyphr::encrypt_string(.challenge_string, key))
      private$.connection <- convertRaw(cyphr::encrypt_object(private$.lstar$as_list(), key))

    },

    authenticate = function(key, sid) {
      self$touch()
      if (!sid %in% private$.unique_hosts) {
        private$.unique_hosts <- append(private$.unique_hosts, sid)
      }

      if (authenticate_key(key=key, encrypted=private$.challenge)) {
        cli::cli_alert_success("key validated")
        return(private$.connection)
      }
      # cli::cli_alert_danger("incompatible password key provided") logging elsewhere
      private$failed_conn_count <- private$failed_conn_count + 1
      return(NA)
    },

    status = function() {
      cli::cli_alert_info(
        stringr::str_interp(
          "[${private$connection_count}] connections from [${length(private$.unique_hosts)}] process(es)."))
    },

    touch = function() {
      private$connection_count <- private$connection_count + 1
    }

  ),

  private = list(
    .lstar = NA,
    .directory = NA,
    .challenge = NA,
    .connection = NA,
    .unique_hosts = list(),
    connection_count = 0,
    failed_conn_count = 0,


    set_key = function(key, file="key.rds") {
      dest <- file.path(private$.directory, file)
      v <- c(key2str(key))
      cli::cli_alert(stringr::str_interp("saving session key to [${dest}]"))
      saveRDS(v, dest)
    }

  )
)

