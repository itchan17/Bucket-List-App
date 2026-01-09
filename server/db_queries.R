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
get_all_active_goals <- function(conn)  {
  query <- "
        SELECT * FROM goals WHERE is_completed = FALSE ORDER BY goal_id DESC 
      "
  goals = dbGetQuery(conn, query)
  
  return(goals)
}

get_all_achievements <- function(conn)  {
  query <- "
        SELECT * FROM goals WHERE is_completed = TRUE ORDER BY goal_id DESC 
      "
  goals = dbGetQuery(conn, query)
  
  return(goals)
}

# Get all the steps of the goal
get_all_goal_steps <- function(conn, goal_id) {
  query <- "
        SELECT step_id, title, is_done, goal_id FROM steps WHERE goal_id = $1 ORDER BY updated_at ASC
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
            SET title = $1, 
            is_done = FALSE, 
            updated_at = CURRENT_TIMESTAMP 
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

update_step_status <- function(conn, step_id) {
  query <- "
    UPDATE steps
    SET is_done = NOT is_done
    WHERE step_id = $1
  "
  
  dbExecute(conn, query, params = list(step_id))
}

update_goal_status <- function(conn, goal_id) {
  query <- "
    UPDATE goals g
    SET is_completed = COALESCE(
      (
        SELECT BOOL_AND(is_done)
        FROM steps
        WHERE goal_id = g.goal_id
      ),
      FALSE
    )
    WHERE g.goal_id = $1
  "
  
  dbExecute(conn, query, params = list(goal_id))
}

calculate_xp <- function(conn) {
  query <- "
    SELECT
      g.goal_id,
      
      -- XP from steps
      COALESCE(SUM(CASE WHEN s.is_done THEN 2 ELSE 0 END), 0) AS step_xp,
      
      -- XP from goal completion
      MAX(
        CASE 
          WHEN g.is_completed AND g.difficulty = 'Simple Steps' THEN 10
          WHEN g.is_completed AND g.difficulty = 'Challenge Quests' THEN 30
          WHEN g.is_completed AND g.difficulty = 'Epic Achievements' THEN 50
          ELSE 0
        END
      ) AS goal_xp,
      
      -- Total XP
      (COALESCE(SUM(CASE WHEN s.is_done THEN 2 ELSE 0 END), 0) +
       MAX(
         CASE 
           WHEN g.is_completed AND g.difficulty = 'Simple Steps' THEN 10
           WHEN g.is_completed AND g.difficulty = 'Challenge Quests' THEN 30
           WHEN g.is_completed AND g.difficulty = 'Epic Achievements' THEN 50
           ELSE 0
         END
       )
      ) AS total_xp
    
    FROM goals g
    LEFT JOIN steps s ON s.goal_id = g.goal_id
    GROUP BY g.goal_id, g.is_completed, g.difficulty
    ORDER BY g.goal_id;
  "
  
  data <- dbGetQuery(conn, query)
  
  return(data)
}

 upload_profile_image <- function (conn, file_name, file_path) {
   
   query  <- "
     INSERT INTO profile_images(profile_image_id, file_name, file_path)
     VALUES ($1, $2, $3)
     ON CONFLICT (profile_image_id)
     DO UPDATE SET
      file_name = EXCLUDED.file_name,
      file_path = EXCLUDED.file_path,
      updated_at = NOW()
     RETURNING file_path
   "
   
   result <- dbGetQuery(conn, query, params = list(
     TRUE,
     file_name,
     file_path
   ))
   
   return(result$file_path)
 }
 
 get_profile_image <- function (conn) {
   query  <- "
    SELECT file_path FROM profile_images
    WHERE profile_image_id = $1
    LIMIT 1
   "
  
   result <- dbGetQuery(conn, query,  params = list(TRUE))
   
   return(result$file_path[1])
 }
 
 get_profile_details <-  function (conn) {
   query <- "
     SELECT
     
       COUNT(DISTINCT g.goal_id) FILTER (WHERE is_completed = true) AS goals_count, 
       COUNT(DISTINCT g.goal_id) FILTER (WHERE difficulty = 'Simple Steps' AND is_completed = true) AS simple_steps_count,
       COUNT(DISTINCT g.goal_id) FILTER (WHERE difficulty = 'Challenge Quests' AND is_completed = true) AS challenge_quests_count,
       COUNT(DISTINCT g.goal_id) FILTER (WHERE difficulty = 'Epic Achievements' AND is_completed = true) AS epic_achievements_count,
       COUNT(s.step_id) FILTER (WHERE is_done = true) AS steps_count
       
     FROM goals g
     LEFT JOIN steps s ON s.goal_id = g.goal_id
   "
   
   data <- dbGetQuery(conn, query)
   
   print(data)
   
   return(data)
 }
 