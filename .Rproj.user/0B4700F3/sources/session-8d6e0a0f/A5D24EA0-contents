library(shiny)

source("client/ModalForm.R")
source("client/MainLayout.R")
options(shiny.autoreload = TRUE)

# Define UI for application that draws a histogram
ui <- fillPage(
    theme = NULL,
    
    tags$head(
      # Tailwind CDN
      tags$script(src = "https://cdn.tailwindcss.com"),
      
      modalFormJS()
    ),
    
    modalFormUI(),
    mainLayout(),
  

)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  observeEvent(input$open_modal_btn, {
    showModal(openModalForm())
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
