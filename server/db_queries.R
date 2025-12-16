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
get_all_goal_steps <- function(conn, goalId) {
  query <- "
        SELECT * FROM steps WHERE goal_id = $1 ORDER BY step_id ASC
      "
  
  steps <- dbGetQuery(conn, query,  params = list(goalId))
  
  return(steps)
}