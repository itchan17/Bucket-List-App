# Handles  query for inserting goals in table
insert_goal<- function(conn, title, category, difficulty)  {
  query <- "
        INSERT INTO goals(title, category, difficulty)
        VALUES ($1, $2, $3)
        RETURNING goal_id
      "
  
  result <- dbGetQuery(conn, query, params = list(
    title,
    category,
    difficulty
  ))
  
  return(result$goal_id)
}

# Handles query for inserting steps  in table
insert_steps <- function (conn, goal_id,  steps) {
  if(length(steps) == 0) return()
  
  query <- "
        INSERT INTO steps (goal_id, title)
        VALUES ($1, $2)
      "
  for (step in steps){
    dbExecute(conn, query, params = list(
      goal_id,
      step
    ))
  }
}

# Handles getting all the goals
get_all_goals <- function(conn)  {
  query <- "
        SELECT * FROM goals ORDER BY goal_id DESC
      "
  goals = dbGetQuery(conn, query)
  
  return(goals)
}

# Get all the steps of the goal
get_all_goal_steps <- function(conn, goal_id) {
  query <- "
        SELECT step_id, title FROM steps WHERE goal_id = $1 ORDER BY updated_at ASC
      "
  
  steps <- dbGetQuery(conn, query,  params = list(goal_id))
  
  return(steps)
}

# Get a single goal by ID
get_goal_by_id <- function(conn, goal_id) {
  query <- "SELECT * FROM goals WHERE goal_id = $1"
  result <- dbGetQuery(conn, query, params = list(goal_id))
  
  if (nrow(result) > 0) {
    return(result[1, ])
  }
  return(NULL)
}

# ============================================================================
# UPDATE OPERATIONS
# ============================================================================

# Update an existing goal
update_goal <- function(conn, goal_id, title, category, difficulty) {
  query <- "UPDATE goals 
            SET title = $1, category = $2, difficulty = $3, updated_at = CURRENT_TIMESTAMP 
            WHERE goal_id = $4"
  dbExecute(conn, query, params = list(title, category, difficulty, goal_id))
  return(goal_id)
}

update_step <- function(conn, step, step_id) {
  query <- "UPDATE steps 
            SET title = $1, updated_at = CURRENT_TIMESTAMP 
            WHERE step_id = $2"
  
  dbExecute(conn, query, params = list(step, step_id))
}

insert_step <- function(conn, goal_id, step) {
  query <- "
        INSERT INTO steps (goal_id, title)
        VALUES ($1, $2)
      "
  
  dbExecute(conn, query, params = list(
    goal_id,
    step
  ))
}

delete_single_step <- function(conn, step_id) {
  query <- "DELETE FROM steps WHERE step_id = $1"
  
  dbExecute(conn, query, params = list(step_id))
}

delete_goal <- function(conn, goal_id) {
  query <- "DELETE FROM goals WHERE goal_id = $1"
  
  dbExecute(conn, query, params = list(goal_id))
}
