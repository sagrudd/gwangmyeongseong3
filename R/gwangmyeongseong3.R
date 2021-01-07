

silent_stop <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop("\r ", call.=FALSE)
}


# https://stackoverflow.com/questions/42734547/generating-random-strings
randString <- function(characters=0, numbers=0, symbols=0, lowerCase=0, upperCase=0) {
  ASCII <- NULL
  if(symbols>0)    ASCII <- c(ASCII, sample(c(33:47, 58:34, 91:96, 123:126), symbols))
  if(numbers>0)    ASCII <- c(ASCII, sample(48:57, numbers))
  if(upperCase>0)  ASCII <- c(ASCII, sample(65:90, upperCase))
  if(lowerCase>0)  ASCII <- c(ASCII, sample(97:122, lowerCase))
  if(characters>0) ASCII <- c(ASCII, sample(c(65:90, 97:122), characters))

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
