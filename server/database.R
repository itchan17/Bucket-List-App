library(DBI)
library(RPostgres)
library(dotenv)

# Load environment variables from .env file

create_connection <- function() {
  tryCatch({
    conn <- DBI::dbConnect(
      RPostgres::Postgres(),
      host = Sys.getenv("PGHOST"),
      port = as.integer(Sys.getenv("PGPORT")),
      dbname = Sys.getenv("PGDATABASE"),
      user = Sys.getenv("PGUSER"),
      password = Sys.getenv("PGPASSWORD")
    )
    return(conn)
  }, error = function(e) {
    message("Failed to connect to PostgreSQL: ", e$message)
    return(NULL)
  })
}

create_connection()



