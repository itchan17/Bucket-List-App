library(shiny)
library(shinyjs)

source("client/LoginPage.R")
source("client/ModalForm.R")
source("client/MainLayout.R")
source("server/database.R")
source("server/db_queries.R")
source("server/ModalFormServer.R")
source("server/GoalDisplay.R")
source("server/ProgressServer.R")
source("server/LoginServer.R")
source("server/initialize_db.R")


options(shiny.autoreload = TRUE)

conn <- create_connection()


initialize_database(conn)

# Define UI for application 
ui <- fillPage(
    theme = NULL,
    
    useShinyjs(),  
    
    tags$head(
      
      # Tailwind CDN
      tags$script(src = "https://cdn.tailwindcss.com"),
      
      # Check localStorage on page load
      tags$script(HTML("
        $(document).on('shiny:connected', function() {
          if (localStorage.getItem('loggedIn') === 'true') {
            Shiny.setInputValue('login-restore_session', true, {priority: 'event'});
          }
        });
      ")),
      
      modalFormJS()
    ),
    
    uiOutput("dynamic_page")
)

server <- function(input, output, session) {
  
  # Initialize auth FIRST
  auth <- loginServer("login")
  
  # Dynamic UI
  output$dynamic_page <- renderUI({
    if (auth$isLoggedIn()) {
      # Show main app when logged in
      tagList(
        mainLayout(
          "goalDisplay",
          list_goals = goalDisplayUI("goalDisplay"),
          display_details = goalDetailsDisplay("goalDisplay"),
          goalButtons = goalButtons("goalDisplay"),
          display_progress = progressDisplayUI("progressDisplay")
        ),
        modalFormUI("goalModal")
      )
    } else {
      # Show login page when not logged in
     
        loginUI("login")
     
      
    }
  })
  
  # Initialize modules only when logged in
  observe({
    req(auth$isLoggedIn())
    
    progress_functions <- progressServer("progressDisplay", conn)
    
    modal_functions <- modalFormServer("goalModal", 
                                       conn, 
                                       refresh = goal_functions$refresh,
                                       progress_refresh = progress_functions$refresh)
    
    goal_functions <- goalDisplayServer("goalDisplay", 
                                        conn, 
                                        edit_callback = modal_functions$load_goal, 
                                        progress_refresh = progress_functions$refresh)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
