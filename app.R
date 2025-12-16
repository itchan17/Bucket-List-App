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
  
  # Handle create data in server
  modalFormServer("goalModal", conn, refresh = refresh)
  
  # Displays data in the UI
  goalDisplayServer("goalDisplay", conn)
}

# Run the application 
shinyApp(ui = ui, server = server)
