
# x=gwangmyeongseong3::LodestarClient$new()

#' @export
LodestarClient <- R6::R6Class(
  "LodestarClient",
  public = list(
    initialize = function(config="key.rds", server="localhost", port=8888) {
      cli::cli_h1(paste0("Lodestar client authentication"))
      if (!file.exists(config)) {
        cli::cli_alert_danger(stringr::str_interp("Config file [${config}] not found"))
        silent_stop()
      } else {
        cli::cli_alert(stringr::str_interp("loading encryption config file [${config}]"))
        private$.key <- readRDS(config)
        #if (!class(private$.key)=="cyphr_key") {
        #  cli::cli_alert_danger(stringr::str_interp("config key does not appear normal"))
        #  silent_stop()
        #}
      }

      tryCatch(
        {
          cli::cli_alert(stringr::str_interp("Connecting to Lodestar credentials daemon"))
          private$.con <- socketConnection(
            host = server, port = port, blocking = FALSE)
          cli::cli_alert_success("connected to server on [{server}:{port}]")
        },
        error=function(cond) {
          cli::cli_alert_danger(stringr::str_interp("Unable to connect to server - is it running?"))
          silent_stop()
        },
        warning=function(cond) {
          cli::cli_alert_warning(cond$message)
          silent_stop()
        }
      )

      private$authenticate()
      invisible(self)
    },

    close = function() {

      close(private$.con)

    }
  ),

  private = list(
    .key = NA,
    .con = NA,

    authenticate = function() {
      print(private$.key)
      print(svSocket::evalServer(private$.con, 'ls()'))
      # create a fugly string ...
      # print(svSocket::evalServer(private$.con, lodestar$secret, key2str(key)))


      challenge_str <- stringr::str_interp(
        'lodestar$validate_key(key="${private$.key}")')
      print(challenge_str)

      #cat(challenge_str, file = private$.con)
      #res <- NULL
      #while (!length(res)) {
      #  Sys.sleep(0.01)
      #  res <- readLines(private$.con)
      #}
      #cat(res, "\n")
      #res <- svSocket::evalServer(private$.con, eval(parse(text=challenge_str)))
      #print(res)

      query <- paste0('svSocket::evalServer(private$.con,"lodestar$validate_key(key=\'',private$.key,'\')")')
      print(eval(parse(text=query)))
    }
  )
)
