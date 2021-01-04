
.default_service = "lodestar"
.default_keyring = "lodestar"

#' @export
Lodestar <- R6::R6Class(
  "Lodestar",
  public = list(

    initialize = function(backend, keyring=.default_keyring, service=.default_service) {
      # sanity check that the backend is actually an R6 backend from keyring
    },

    print = function(...) {
      cat(paste0(private$.getpasswd()))
    }

  ),

  private = list(
    .keyring = NA,

    .get_passwd = function() {
      return(.keyring$get(keyring = keychain_name, service=kr_service, username=kr_username))
    }
  )
)


#' @importFrom magrittr %>%
#' @export
LodestarConn <- R6::R6Class(
  "LodestarConn",
  public = list(
    initialize = function(backend=NA, keyring=.default_keyring, service=.default_service, username=NA, silent=FALSE) {
      if (is.na(backend)) {
        if (!silent) message(paste0("using keyring settings for LodestarConn"))
        private$.backend = keyring::backend_file$new()
      } else {
        private$.backend = backend
      }
      private$.keyring = keyring
      private$.service = service
      private$.silent = silent
      private$.username = username
      private$.check_backend()
    },

    connection = function() {
      con <- DBI::dbConnect(
        RPostgres::Postgres(),
        dbname = private$.service,
        host="localhost",
        port=5432,
        user=private$.username,
        password=private$.password)
    }
  ),

  private = list(
    .backend = NA,
    .keyring = NA,
    .service = NA,
    .username = NA,
    .silent = NA,
    .password = NA,

    .check_backend = function() {
      classes <- class(private$.backend)
      if (!all(c("backend", "R6") %in% classes)) {
        stop("Is the provided object really a keyring backend?")
      }
      key_rings <- as.vector(unlist(private$.backend$keyring_list()[1]))

      if (!private$.keyring %in% key_rings) {
        if (private$.keyring == .default_keyring) {
          stop("Have you defined your Lodestar users?")
        }
        stop(paste0("keyring [",private$.keyring,"] not found in backend keyset"))
      } else {
        if (!private$.silent) message(paste0("using [",private$.keyring,"] as session keyset"))
      }

      tib <- tibble::as_tibble(private$.backend$list(keyring=private$.keyring))

      if (is.na(private$.username)) {
        if (!private$.silent) message(paste0("trying to pick a suitable username"))
        if (!private$.service %in% tib$service) {
          stop(paste0("service [",private$.service,"] is not present in keyring"))
        }
        tib <- tib %>% dplyr::filter(service==private$.service)
        if (length(unique(tib$username))>1) {
          stop(paste0(
            "username is ambiguous with [",length(unique(tib$username)),
            "] possibilities\n", paste0("[", paste(c("stephen", "kevin"), collapse="], ["), "]")))
        } else if (length(unique(tib$username))==0) {
          stop(paste0("There do not appear to be any suitable candidate usernames"))
        } else if (length(unique(tib$username)) == 1) {
          private$.username <- unique(tib$username)[1]
          if (!private$.silent) message(paste0("using [",private$.username,"] as a username"))
        }
      } else {
        if (!private$.username %in% tib$username) {
          stop(paste0("username [",private$.username,"] is not present in keyring"))
        } else if (!private$.service %in% tib$service) {
          stop(paste0("service [",private$.service,"] is not present in keyring"))
        }
        tib <- tib %>% dplyr::filter(service==private$.service) %>% dplyr::filter(username==private$.username)
        if (length(unique(tib$username))==0) {
          stop(paste0("No candidate entries for [sevice=",private$.service,", username=",private$.username,"]"))
        }
      }

      private$.password <- private$.backend$get(keyring = private$.keyring, service=private$.service, username=private$.username)
      if (!private$.silent) message(paste0("password [","*****","] recovered"))

    }
  )

)


#' @export
lodestar_user_tibble = function() {
  users <- list()
  xkey <- function(x) {
    user_items = backend$list(keyring=x)
    for (i in seq(nrow(user_items))) {
      items <- c(keyring=x, service=user_items$service[i], username=user_items$username[i])
      pointer <- length(users) + 1
      users[[pointer]] <<- items
    }
    return(x)
  }
  backend <- keyring::backend_file$new()
  keyrings <- as.vector(unlist(backend$keyring_list()[1]))
  lapply(keyrings, xkey)
  tibble::as_tibble(do.call("rbind",users))
}



#' @export
lodestar_creds = function(username, password, service=.default_service, keyring=.default_keyring) {
  backend <- keyring::backend_file$new()
  if (!keyring %in% unlist(backend$keyring_list()[1])) {
    backend$keyring_create(keyring)
  }
  backend$set_with_value(service=service, username=username, password=password, keyring=keyring)
  invisible(backend)
}
