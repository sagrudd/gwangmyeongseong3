#
# # https://www.r-bloggers.com/2020/08/a-crash-course-on-postgresql-for-r-users/
# # https://stackoverflow.com/questions/30729757/how-does-one-specify-a-primary-key-when-using-dplyr-copy-to
#
# library(RPostgres)
# library(dplyr)
# fun_connect <- function() {
#   dbConnect(
#     Postgres(),
#     dbname = Sys.getenv("tutorial_db"),
#     user = Sys.getenv("tutorial_user"),
#     password = Sys.getenv("tutorial_pass"),
#     host = Sys.getenv("tutorial_host")
#   )
# }
#
#
# unique_index <- list(
#   airlines = list("carrier"),
#   planes = list("tailnum")
# )
#
#
# index <- list(
#   airports = list("faa"),
#   flights = list(
#     c("year", "month", "day"), "carrier", "tailnum", "origin", "dest"
#   ),
#   weather = list(c("year", "month", "day"), "origin")
# )
#
#
#
#
#
# local_tables <- utils::data(package = "nycflights13")$results[, "Item"]
# tables <- setdiff(local_tables, remote_tables)
# for (table in tables) {
#   df <- getExportedValue("nycflights13", table)
#   message("Creating table: ", table)
#   table_name <- table
#   conn <- fun_connect()
#   copy_to(
#     conn,
#     df,
#     table_name,
#     unique_indexes = unique_index[[table]],
#     indexes = index[[table]],
#     temporary = FALSE
#   )
#   dbDisconnect(conn)
# }
#
#
#
#
#
# #set primary key
# dbExecute(hflights_db$con,
#           "ALTER TABLE flights
#            ADD PRIMARY KEY (`key`);"
# )
#
#
#
