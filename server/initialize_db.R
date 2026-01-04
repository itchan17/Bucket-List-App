library(DBI)
library(RPostgres)
library(digest)

initialize_database <- function(conn) {
  
  message("Initializing database tables...")
  
  # Create goals table
  DBI::dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS goals (
      goal_id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      difficulty VARCHAR(255) NOT NULL,
      category VARCHAR(255) NOT NULL,
      is_completed BOOLEAN DEFAULT false,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  # Create steps table (with foreign key to goals)
  DBI::dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS steps (
      step_id SERIAL PRIMARY KEY,
      goal_id INTEGER NOT NULL REFERENCES goals(goal_id) ON DELETE CASCADE,
      title VARCHAR(255) NOT NULL,
      is_done BOOLEAN DEFAULT false,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  
  message("Database initialized successfully!")
}