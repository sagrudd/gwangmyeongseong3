
.default_service = "lodestar"
.default_keyring = "lodestar"



#' R6 Class for abstracting database connections and maintaining lodestar schema
#'
#' @description
#' This class aims to provide some basic minimal functionality for interacting
#' with a Lodestar schema in a relational database. A key ambition at outset
#' has been the separation of user credentials and demonstration code for the
#' preparation of examples and documentation in the vignettes.
#'
#' @import R6
#' @importFrom magrittr %>%
#' @importFrom DBI dbConnect
#' @importFrom RPostgres Postgres
#' @export
LodestarConn <- R6::R6Class(
  "LodestarConn",
  public = list(

    #' @description
    #' Creates a new LodestarConn object. This
    #' initialisation method orchestrates other sanity checking
    #' of the defined parameters(s) to ensure that the environment is coherent
    #' and tractable
    #'
    #' @param backend keyring backend object used to define username and
    #' password independently of the vignette code (persistence) - NA by default
    #' - software will endeavour to select backend on basis of available
    #' keyring context
    #' @param keyring which of the available keyrings will hold the connection
    #' details - `lodestar` by default.
    #' @param service the name of the database that we'll endeavour to connect
    #' to - this will be parsed from the backend context - `lodestar` by
    #' default.
    #' @param username the user account to be used with the database - NA by
    #' default; in simpler installations the software will identify the username
    #' on basis of e.g. service
    #' @param password the password to connect to the database with; using the
    #' backend object this can be read from the keyring
    #' @param silent boolean defining whether logging of process should be
    #' performed (TRUE by default)
    #' @return the LodestarConn R6 object
    #'
    initialize = function(backend=NA, keyring=.default_keyring, service=.default_service, username=NA, password=NA, port=5432, silent=FALSE) {
      if (!is.na(backend)) {
        private$.backend = backend
      }
      private$.keyring <- keyring
      private$.service <- service
      private$.silent <- silent
      private$.username <- username
      private$.password <- password
      private$.port <- as.integer(port)

      private$.check_backend()
      invisible()
    },

    #' @description
    #' Get a database connection corresponding to the passed parameters
    #'
    #' @return a DBI connection object
    connection = function() {
      DBI::dbConnect(
        RPostgres::Postgres(),
        dbname = private$.service,
        host="localhost",
        port=private$.port,
        user=private$.username,
        password=private$.password)
    },

    #' @description
    #' export the key characteristics of this object in a format for writing
    #' to YAML to allow the propagation of settings in a cluster environment
    #' where we cannot expect processes to have access to the keyring - this
    #' does mean that connection strings and passwords are written to file ...
    #' this will be addressed more securely once we're beyond the proof-of-
    #' concept.
    as_list = function() {
      return(
        list(
          username=private$.username,
          password=private$.password,
          rdbms=private$.keyring,
          database=private$.service,
          port=private$.port
        ))
    },


    list_tables = function(schema="public") {
      conn <- self$connection()
      query = stringr::str_interp(
        "select table_catalog, table_schema, table_name from information_schema.tables where table_schema='${schema}'")
      if (!private$.silent) {
        cli::cli_alert(query)
      }
      remote_tables <- DBI::dbGetQuery(conn, query)
      DBI::dbDisconnect(conn)
      return(tibble::as_tibble(remote_tables))
    },


    drop_table = function(table) {
      conn <- self$connection()
      query = stringr::str_interp(
        "drop table if exists ${table}")
      if (!private$.silent) {
        cli::cli_alert(query)
      }
      response <- DBI::dbExecute(conn, query)
      DBI::dbDisconnect(conn)
      invisible()
    },


    fastx_upload = function(dna, table="cluster_fasta", fastx="fasta") {

      if ("DNAStringSet" %in% class(dna)) {
        conn <- self$connection()
        count <- length(dna)
        cli::cli_alert(stringr::str_interp("importing [${count}] sequences into sequence table [${table}]"))
        dna_tib <- tibble::tibble(accession=names(dna), width=dna@ranges@width, sequence=unlist(as.character(dna)))
        DBI::dbWriteTable(conn, table, dna_tib,
                          row.names=FALSE, append=TRUE, field.types=NULL, copy=TRUE)
        DBI::dbDisconnect(conn)
        cli::cli_alert_success("database transaction complete")
      } else {
        cli::cli_div(theme = list(span.emph = list(color = "orange")))
        cli::cli_alert_warning("{.emph fastx_upload} requires a {.emph DNAStringSet} object - upload failed")
      }
    }

  ),

  private = list(
    .backend = NA,
    .keyring = NA,
    .service = NA,
    .username = NA,
    .silent = NA,
    .password = NA,
    .port = NA,

    .check_backend = function() {
      if (!is.na(private$.username) & !is.na(private$.password)) {
        cli::cli_alert("using provided [user:pass] information")
        return(invisible())
      }

      if (is.na(private$.backend)) {
        cli::cli_alert("creating a new backend keychain for lodestar")
        private$.backend = keyring::backend_file$new()
      } else {
        classes <- class(private$.backend)
        if (!all(c("backend", "R6") %in% classes)) {
          cli::cli_alert_danger("Is the provided object really a keyring backend?")
          silent_stop()
        }
      }

      key_rings <- as.vector(unlist(private$.backend$keyring_list()[1]))

      if (!private$.keyring %in% key_rings) {
        if (private$.keyring == .default_keyring) {
          cli::cli_alert_danger("Have you defined your Lodestar users?")
          silent_stop()
        }
        cli::cli_alert_danger(paste0("keyring [",private$.keyring,"] not found in backend keyset"))
        silent_stop()
      } else {
        cli::cli_alert(paste0("using [",private$.keyring,"] as session keyset"))
      }

      tib <- tibble::as_tibble(private$.backend$list(keyring=private$.keyring))

      if (is.na(private$.username)) {
        if (!private$.service %in% tib$service) {
          cli::cli_alert_danger(paste0("service [",private$.service,"] is not present in keyring"))
          silent_stop()
        }
        tib <- tib %>% dplyr::filter(service==private$.service)
        if (length(unique(tib$username))>1) {
          cli::cli_alert_danger(paste0(
            "username is ambiguous with [",length(unique(tib$username)),
            "] possibilities\n", paste0("[", paste(unique(tib$username), collapse="], ["), "]")))
          stop()
        } else if (length(unique(tib$username))==0) {
          unique(tib$username)(paste0("There do not appear to be any suitable candidate usernames"))
        } else if (length(unique(tib$username)) == 1) {
          private$.username <- unique(tib$username)[1]
          cli::cli_alert_success(paste0("using [",private$.username,"] as a username"))
        }
      } else {
        if (!private$.username %in% tib$username) {
          cli::cli_alert_danger(paste0("username [",private$.username,"] is not present in keyring"))
          silent_stop()
        } else if (!private$.service %in% tib$service) {
          cli::cli_alert_danger(paste0("service [",private$.service,"] is not present in keyring"))
          silent_stop()
        }
        tib <- tib %>% dplyr::filter(service==private$.service) %>% dplyr::filter(username==private$.username)
        if (length(unique(tib$username))==0) {
          cli::cli_alert_danger(paste0("No candidate entries for [sevice=",private$.service,", username=",private$.username,"]"))
          silent_stop()
        }
      }

      private$.password <- private$.backend$get(keyring = private$.keyring, service=private$.service, username=private$.username)
      cli::cli_alert_success(paste0("password [","*****","] recovered"))

    }
  )

)


#' Prepare a summary of available keyring annotations
#'
#' In a larger SQL environment there is a possibility of 10s of different
#' RDBMS systems and considerable numbre of database instances - this simple
#' method prepares a tibble that summarises the available keyring, service and
#' username information for reminding the available connection possibilities
#'
#' @return a tibble
#'
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


#' Inject a username and password into the backend keyring environment
#'
#' We are working here to prepare a clean system for the simple and ad hoc
#' analysis of high dimensional sequence data. This accessory method is intended
#' to help define the limits of RDBMS, database, username and password required
#' for connecting to the most appropriate systems.
#'
#' @param username username
#' @param password password
#' @param service the database to use
#' @param keyring the keyring where credentials will be stored
#'
#' @return backend instance
#'
#' @export
lodestar_creds = function(username, password, service=.default_service, keyring=.default_keyring) {
  backend <- keyring::backend_file$new()
  if (!keyring %in% unlist(backend$keyring_list()[1])) {
    backend$keyring_create(keyring)
  }
  backend$set_with_value(service=service, username=username, password=password, keyring=keyring)
  invisible(backend)
}
