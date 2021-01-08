
#.config2yaml = "config2yaml"
.lodestarupload = "upload"
.lodestardaemon = "daemon"


#' Lodestar controller - for calling from Rscript
#'
#' A load of the Lodestar code is intended to be run through NextFlow scripts;
#' this function provides some control infrastructure for the usage of the
#' package through the commandline in so far is possible using R
#' e.g. `Rscript -e 'gwangmyeongseong3::lodestar()'`
#'
#' @return nothing much
#'
#' @importFrom cli cli_alert_danger
#' @importFrom cli cli_alert_success
#' @importFrom optparse parse_args
#' @importFrom optparse make_option
#' @importFrom optparse OptionParser
#' @importFrom optparse print_help
#'
#' @export
lodestar = function() {
  cli::cli_alert_success("Welcome to lodestar annotator")
  tasks = c(.lodestarupload, .lodestardaemon)

  option_list = list(
    optparse::make_option(
      c("--action", "-a"), dest="activity",
      type="character", default=NULL,
      help=paste0(
        "Lodestar action to perform ",
        paste0("[", paste(tasks, collapse=", "), "]")),
      metavar="character"),

    optparse::make_option(
      c("-c", "--config"), type="character", default="config.yaml",
      help="configuration file [default=%default]", metavar="character"),
    optparse::make_option(
      c("-d", "--database"), type="character", default=.default_service,
      help="database instance [default=%default]", metavar="character"),
    optparse::make_option(
      c("-p", "--password"), type="character", default=NA,
      help="password [default=%default]", metavar="character"),
    optparse::make_option(
      c("-r", "--rdbms"), type="character", default=.default_keyring,
      help="RDBMS connection [default=%default]", metavar="character"),
    optparse::make_option(
      c("-u", "--username"), type="character", default=NA,
      help="username [default=%default]", metavar="character")
  );

  opt_parser = optparse::OptionParser(option_list=option_list);
  opt = optparse::parse_args(opt_parser);

  if (is.null(opt$activity)){
    optparse::print_help(opt_parser)
    cli::cli_alert_danger("An activity must be defined")
    silent_stop()
  } else if (!opt$activity %in% tasks) {
    optparse::print_help(opt_parser)
    cli::cli_alert_danger(paste0("[",opt$activity,"] is not a defined activity"))
    silent_stop()
  } else if (opt$activity == .lodestarupload) {
    lodestar_upload(opt)
  } else if (opt$activity == .lodestardaemon) {
    lodestar_daemon(opt)
  } else {
    cli::cli_alert_danger("method definition not yet implemented ...")
  }
}

#' #' @importFrom yaml write_yaml
#' lodestar_make_yaml = function(opt) {
#'   cli::cli_h1("creating YAML config file")
#'   cli::cli_alert_info(paste0("using [",opt$config,"] as YAML destination"))
#'   lsc <- LodestarConn$new(
#'     keyring=opt$rdbms,
#'     service=opt$database,
#'     username=opt$username,
#'     password=opt$password)
#'   yaml::write_yaml(lsc$as_yaml(), opt$config)
#'   cli::cli_alert_success(paste0("[",opt$config,"] written successfully"))
#' }


lodestar_upload = function(opt) {
  cli::cli_h1("uploading bulk fastx to lodestar")
  if (!all(c(
    file.exists(opt$config)))) {
    cli::cli_alert_danger(paste0("config file [",opt$config,"] not found - please create"))
    silent_stop()
  }
  config <- yaml::yaml.load_file(opt$config)
  print(config)
}


lodestar_daemon = function(opt) {

  lsc <- LodestarConn$new(
    keyring=opt$rdbms,
    service=opt$database,
    username=opt$username,
    password=opt$password)

  ldaemon <- LodestarDaemon$new(lsc)
  cli::cli_alert("Press ctrl-c to stop lodestar daemon")

  tryCatch(
    while (ldaemon$is_running()) {
      Sys.sleep(0.5)
      cat(paste0("\r",ldaemon$daemon_status()))
    },
    interrupt = ldaemon$daemon_stop,
    finally = ldaemon$daemon_stop()
  )
}

