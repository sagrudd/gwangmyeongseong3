
# x=gwangmyeongseong3::LodestarClient$new()$close()

#' @export
LodestarClient <- R6::R6Class(
  "LodestarClient",
  public = list(
    initialize = function(server="127.0.0.1", port="8888", config="key.rds") {
      cli::cli_h1(paste0("Lodestar client authentication"))
      if (!file.exists(config)) {
        silent_stop(stringr::str_interp("Config file [${config}] not found"))
      } else {
        cli::cli_alert(stringr::str_interp("loading encryption config file [${config}]"))
        v <- readRDS(config)
        private$.key <- v[1]
      }

      private$.server <- server
      private$.port <- port

      private$preflight_check()
      private$authenticate()

      invisible(NULL)
    }

  ),

  private = list(
    .key = NA,
    .server = NA,
    .port = NA,
    .sid = randString(characters=15),
    lodestar_conn = NA,


    get_curl = function(query) {
      qualified_query = stringr::str_interp("http://${private$.server}:${private$.port}/${query}")
      cli::cli_alert(qualified_query)
      return(curl::curl_fetch_memory(qualified_query))
    },

    preflight_check = function(test="test_string") {
      query <- "preflight_check" %>%
        urltools::param_set(key="key", value="test")

      response = private$get_curl(query)
      if (response$status_code == "200") {
        if (is.logical(yaml::read_yaml(text=rawToChar(response$content)))) {
          cli::cli_alert_success("server providing lodestar API validated")
          return(is.logical(yaml::read_yaml(text=rawToChar(response$content))))
        }
      }
      silent_stop(stringr::str_interp("preflight checks failed = [${response$status_code}]"))
    },


    authenticate = function() {
      query <- "authenticate" %>%
        urltools::param_set(key="key", value=private$.key) %>%
        urltools::param_set(key="sid", value=private$.sid)

      response = private$get_curl(query)
      settings <- yaml::read_yaml(text=rawToChar(response$content))
      if (is.null(settings) || (length(settings)==1 && is.null(settings[[1]]))) {
        silent_stop("credential transfer rejected - your token may be stale")
      } else {
        key <- str2key(private$.key)
        mylist <- cyphr::decrypt_object(gwangmyeongseong3:::convertSHex(settings), key)
        private$lodestar_conn <- LodestarConn$new(keyring=mylist$rdbms, service=mylist$database, username=mylist$username, password=mylist$password, port=mylist$port)
      }
    }
  )
)
