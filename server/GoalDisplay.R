# Function used to passed in the MainLayout to display the goals
goalDisplayUI <- function(id) {
  ns <- NS(id)
  
  # This displays the list of goals
  uiOutput(ns("display_goal_list")) 
}

# Function used to passed in the MainLayout to display the goal details
goalDetailsDisplay <- function(id) {
  ns <- NS(id)
  
  # This displays the list of goals
  uiOutput(ns("display_goal_details"),
           class = "row-span-4 flex flex-col col-span-2 md:col-span-1 h-full") 
}

# Backend logic for displaying data
goalDisplayServer <- function(id, conn, edit_callback = NULL) {
  moduleServer(id, function(input, output, session) {
    
    # Used to refresh  the goals data
    refresh_trigger <- reactiveVal(0)
    
    goals_data <- reactive({
      refresh_trigger() # dependency
      
      # wrapper to prevent errors if connection fails
      tryCatch({
        get_all_goals(conn)
      }, error = function(e) {
        print(paste("DATABASE ERROR:", e$message))
        data.frame() # return empty df on error
      })
    })
    
    # This displays the list  of goals
    output$display_goal_list <- renderUI({
      ns <- session$ns  
      goals <-  goals_data()
      
      if (nrow(goals) == 0) {
        return()
      }
      
      tagList(
        lapply(1:nrow(goals), function(i) {
          
          row <- goals[i, ]
          
          click_goal <- sprintf(
            "Shiny.setInputValue('%s', %d, {priority: 'event'})", 
            ns("clicked_goal"), 
            row$goal_id 
          )
          
          edit_goal <- sprintf(
            "event.stopPropagation(); openModal(); Shiny.setInputValue('%s', %d, {priority: 'event'})", 
            ns("edit_goal"), 
            row$goal_id 
          )
          
          delete_goal <- sprintf(
            "event.stopPropagation(); Shiny.setInputValue('%s', %d, {priority: 'event'})", 
            ns("delete_goal"), 
            row$goal_id 
          )
          
          div(
            onclick = click_goal,
            class = "px-6 py-4 cursor-pointer hover:bg-[#DDBA7D] transform-all duration-300 
              active:scale-95 rounded flex justify-between",
            span(
              row$title,
              class = "text-3xl "
            ),
            div(
              class = "flex gap-5",
              # Edit button
              tags$button(
                icon("fa-solid fa-pen-to-square", class = "text-[#CF4B00] text-4xl"),
                class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                onclick = edit_goal
              ),
              # Delete button
              tags$button(
                icon("fa-solid fa-x", class = "text-[#CF4B00] text-4xl"),
                class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                onclick = delete_goal
              )
            )
          )
        })
      )
    })
  
    # When a goal was clicked it saves the id of the goals 
    observeEvent(input$clicked_goal, {
      selectedGoalId(input$clicked_goal)
    })
    
    selectedGoalId <- reactiveVal(NULL)
    
    # Display the details of the goal
    output$display_goal_details <- renderUI({
      
      # Check if there's selected goals
      # If none set the data to display to empty
      if(is.null(selectedGoalId())){
        category  <- ""
        difficulty  <- ""
        
        steps      <- data.frame()
      } else {
        
        # Get the goal data from the existing data
        goalData <- goals_data()[goals_data()$goal_id == selectedGoalId(), ]
        
        category  <- goalData$category
        difficulty  <- goalData$difficulty
        
        # Get the steps from the database
        steps <-  tryCatch({
          get_all_goal_steps(conn, goalData$goal_id)
        }, error = function(e) {
          print(paste("DATABASE ERROR:", e$message))
          data.frame() # return empty df on error
        })
      }
      
      # Display the details
      tagList(
          h1(
            "Details", 
            class = "text-4xl font-bold mb-3" 
          ),
          div(
            class = "w-full shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 mb-10",
            h2(
              paste("Category: ", category), 
              class = "text-2xl font-bold" 
            ),
            h2(
              paste("Difficulty: ", difficulty), 
              class = "text-2xl font-bold" 
            ),
          ),
          h1(
            "Steps", 
            class = "text-3xl font-bold mb-3" 
          ),
          div(
            class = "w-full shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 flex-1 flex flex-col overflow-y-auto ",
            
            # List the steps
            if (nrow(steps) > 0) {
              lapply(1:nrow(steps), function(i) {
                row <- steps[i, ]
                div(
                  class = "flex items-end space-x-5
                px-6 py-4 hover:bg-[#DDBA7D] transform-all duration-300 rounded",
                  
                  tags$input(
                    type = "checkbox",
                    class = "w-9 h-9 accent-[#CF4B00]"
                  ),
                  
                  span(
                    row$title,
                    class = "text-3xl"
                  )
                )
              })
            }
           
          ),
        )
    })
    
    
    observeEvent(input$edit_goal, {
      print(paste("Edit goal clicked:", input$edit_goal))
      
      if (!is.null(edit_callback)) {
        edit_callback(input$edit_goal)
      }
    })
    refresh <- function() {
      refresh_trigger(refresh_trigger() + 1)
    }
    
    return(list(
      refresh = refresh
    )
     
    )
    
  })
}
 
    
 