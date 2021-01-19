# script name:
# plumber.R

option_list = list(
  optparse::make_option(
    c("-d", "--directory"), type="character", default="~/",
    help="username [default=%default]", metavar="character"),
  optparse::make_option(
    c("-u", "--username"), type="character", default=NULL,
    help="username [default=%default]", metavar="character"),
  optparse::make_option(
    c("-p", "--password"), type="character", default=NA,
    help="password", metavar="character"),
  optparse::make_option(
    c("-k", "--keyring"), type="character", default=gwangmyeongseong3:::.default_keyring,
    help="database server [default=%default]", metavar="character"),
  optparse::make_option(
    c("-s", "--service"), type="character", default=gwangmyeongseong3:::.default_service,
    help="database instance [default=%default]", metavar="character")
)
opt_parser = optparse::OptionParser(option_list=option_list)
opt = optparse::parse_args(opt_parser)

# load the configuration that will be used for this server instance ...
cli::cli_h1("loading lodestar API configuration")

if (is.null(opt$username)){
  optparse::print_help(opt_parser)
  gwangmyeongseong3:::silent_stop("A username must be defined")
}

lodestar_conn <- gwangmyeongseong3::LodestarConn$new(
  username=opt$username, password=opt$password, keyring=opt$keyring,
  service=opt$service)

#lodestar_conn <- gwangmyeongseong3::LodestarConn$new(
#  keyring=opt$keyring, username=opt$username, service=opt$service)
daemon <- gwangmyeongseong3::LodestarDaemon$new(lodestar_conn, opt$directory)
print(daemon)




# https://community.rstudio.com/t/plumber-api-and-package-structure/18099

# set API title and description to show up in http://localhost:8000/__swagger__/

#' @apiTitle Lodestar API for comparative genomics
#' @apiDescription This lodestar API provides a database abstraction layer
#' between R and a relational datatase. This is intended to simplify computing
#' in a distributed environment and borrows thoughts and ideas from the earlier
#' OpenSputnik projects.




#* @param key a string value of a key
#* @get preflight_check
preflight_check = function(key) {
  cli::cli_alert_info("preflight_check requested")
  daemon$touch()
  return(TRUE)
}



#* @param key a string value of cyphr key
#* @param sid - sessionId for the remote R session; can be used for logging
#* @get authenticate
authenticate = function(key, sid) {
  cli::cli_alert_info(
    stringr::str_interp("authentication check requested [${key}::${sid}]"))
  payload <- daemon$authenticate(key=key, sid=sid)
  daemon$status()
  return(payload)
}

