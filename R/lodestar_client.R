
# x=gwangmyeongseong3::LodestarClient$new()$close()

#' @export
LodestarClient <- R6::R6Class(
  "LodestarClient",
  public = list(
    initialize = function(config="key.rds") {
      cli::cli_h1(paste0("Lodestar client authentication"))
      server <- NA
      port <- NA
      if (!file.exists(config)) {
        cli::cli_alert_danger(stringr::str_interp("Config file [${config}] not found"))
        silent_stop()
      } else {
        cli::cli_alert(stringr::str_interp("loading encryption config file [${config}]"))
        v <- readRDS(config)
        server <- v[1]
        port <- v[2]
        private$.key <- v[3]
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

      suppressWarnings(private$authenticate())
      invisible(self)
    },

    close = function() {

      close(private$.con)

    }
  ),

  private = list(
    .key = NA,
    .con = NA,
    .sid = randString(characters=15),
    lodestar_conn = NA,

    authenticate = function() {

      query <- paste0('svSocket::evalServer(private$.con,"lodestar$validate_key(key=\'',private$.key,'\', sid=\'',private$.sid,'\')")')
      response <- eval(parse(text=query))
      if (is.na(response)) {
        cli::cli_alert_danger("credential transfer rejected - your token may be stale")
        silent_stop()
      } else {
        key <- str2key(private$.key)
        mylist <- cyphr::decrypt_object(gwangmyeongseong3:::convertSHex(response), key)
        LodestarConn$new(keyring=mylist$rdbms, service=mylist$database, username=mylist$username, password=mylist$password, port=mylist$port)
      }
    }
  )
)
