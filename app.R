library(shiny)
library(shinyjs)

source("client/ModalForm.R")
source("client/MainLayout.R")
source("server/database.R")
source("server/db_queries.R")
source("server/ModalFormServer.R")
source("server/GoalDisplay.R")

options(shiny.autoreload = TRUE)

conn <- create_connection()

# Define UI for application 
ui <- fillPage(
    theme = NULL,
    
    useShinyjs(),  
    
    tags$head(
      
      # Tailwind CDN
      tags$script(src = "https://cdn.tailwindcss.com"),
      
      modalFormJS()
    ),
    
    mainLayout(list_goals = goalDisplayUI("goalDisplay"),
               display_details = goalDetailsDisplay("goalDisplay")
               ),
    
    modalFormUI("goalModal")
)

server <- function(input, output, session) {
  
  modal_functions <- modalFormServer("goalModal", conn, refresh = goal_functions$refresh)
  
  goal_functions <- goalDisplayServer("goalDisplay", conn, edit_callback = modal_functions$load_goal)
}

# Run the application 
shinyApp(ui = ui, server = server)
