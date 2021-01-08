

silent_stop <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop("\r ", call.=FALSE)
}


# https://stackoverflow.com/questions/42734547/generating-random-strings
randString <- function(characters=0, numbers=0, symbols=0, lowerCase=0, upperCase=0) {
  ASCII <- NULL
  if(symbols>0)    ASCII <- c(ASCII, sample(c(33:47, 58:34, 91:96, 123:126), symbols, replace=TRUE))
  if(numbers>0)    ASCII <- c(ASCII, sample(48:57, numbers, replace=TRUE))
  if(upperCase>0)  ASCII <- c(ASCII, sample(65:90, upperCase, replace=TRUE))
  if(lowerCase>0)  ASCII <- c(ASCII, sample(97:122, lowerCase, replace=TRUE))
  if(characters>0) ASCII <- c(ASCII, sample(c(65:90, 97:122), characters, replace=TRUE))

  return( rawToChar(as.raw(sample(ASCII, length(ASCII)))) )
}


convertRaw = function(x) paste(x,collapse = '')

convertSHex = function(x) as.raw(
  as.hexmode(
    substring(x, seq(1, nchar(x)-1, 2), seq(2, nchar(x), 2))))

key2str = function(key) {
  return(gsub(", ","",toString(key$key())))
}

str2key = function(s) {
  xx <- convertSHex(s)
  class(xx) <- "aes"
  return(cyphr::key_openssl(xx))
}

.challenge_string = "PQ0nt7KvRLAaFZ28fU1946Dq5l3hzVJjWdi"

authenticate_key <- function(key, encrypted, challenge=.challenge_string) {
  cli::cli_h1("trying to validate a key")

  tryCatch(
    {
      mystring <- NA
      mystring <- cyphr::decrypt_string(
        gwangmyeongseong3:::convertSHex(encrypted),
        gwangmyeongseong3:::str2key(key))
    },
    error = function(mess) {

      if (mess$message == "OpenSSL error in EVP_DecryptFinal_ex: bad decrypt") {
        cli::cli_alert_danger("attempted decrypt with invalid key")
      } else if (mess$message == "'x' cannot be coerced to class \"hexmode\"") {
        cli::cli_alert_danger("secret/encrypted is not a string representation of hexkey")
      } else {
        print(mess$message)
      }
    },
    warning = function(mess) {
      print(mess)
    },
    finally = {
      if (!is.na(mystring)) {
        cli::cli_alert_info(mystring)
        if (mystring == challenge) {
          return(TRUE)
        }
      } else {
        cli::cli_alert_danger("mission failed")
      }
    }

  )
  return(FALSE)
}



