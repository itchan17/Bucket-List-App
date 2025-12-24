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

goalButtons <- function(id) {
  ns <- NS(id)
  
  # This displays the list of goals
  uiOutput(ns("buttons")) 
}

# Backend logic for displaying data
goalDisplayServer <- function(id, conn, edit_callback = NULL, progress_refresh = NULL) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # Used to refresh  the goals data
    refresh_trigger <- reactiveVal(0)
    
    goals_data <- reactive({
      refresh_trigger() # dependency
      
      # wrapper to prevent errors if connection fails
      tryCatch({
        if(activeButton() == "active") {
          get_all_active_goals(conn)
        } else {
          get_all_achievements(conn)
        }
      }, error = function(e) {
        print(paste("DATABASE ERROR:", e$message))
        data.frame() # return empty df on error
      })
    })
    
    selectedGoalId <- reactiveVal(NULL)
    
    activeButton <- reactiveVal("active")
    
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
            class = paste("px-6 py-4 cursor-pointer hover:bg-[#DDBA7D] transform-all duration-300 
              active:scale-95 rounded flex justify-between", 
                          if (identical(selectedGoalId(), row$goal_id))
                          "bg-[#DDBA7D]"
                          else
                          ""),
            span(
              row$title,
              class = "text-3xl "
            ),
            if(activeButton() == "active") {
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
            }
          )
        })
      )
    })
  
    # When a goal was clicked it saves the id of the goals 
    observeEvent(input$clicked_goal, {
      selectedGoalId(input$clicked_goal)
    })
    
   
    steps <- reactiveVal()
    
    # Display the details of the goal
    output$display_goal_details <- renderUI({
      
      # Check if there's selected goals
      # If none set the data to display to empty
      if(is.null(selectedGoalId())){
        category  <- ""
        difficulty  <- ""
        
        steps(data.frame())
      } else {
        
        # Get the goal data from the existing data
        goalData <- goals_data()[goals_data()$goal_id == selectedGoalId(), ]
        
        category  <- goalData$category
        difficulty  <- goalData$difficulty
        
        # Get the steps from the database
        steps(
            tryCatch({
            get_all_goal_steps(conn, goalData$goal_id)
          }, error = function(e) {
            print(paste("DATABASE ERROR:", e$message))
            data.frame() # return empty df on error
          })
        )
      }
      
      steps_data <- steps()
    
      
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
            if (nrow(steps_data) > 0) {
              lapply(1:nrow(steps_data), function(i) {
                row <- steps_data[i, ]
          
                checked_step <- sprintf(
                  "Shiny.setInputValue('%s', %d, {priority: 'event'})", 
                  ns("checked_step"), 
                  row$step_id 
                )
                
                
                div(
                  class = "flex items-end space-x-5
                px-6 py-4 hover:bg-[#DDBA7D] transform-all duration-300 rounded",
                  
                  tags$input(
                    type = "checkbox",
                    class = "w-9 h-9 accent-[#CF4B00]",
                    checked = if (row$is_done) "checked" else NULL,
                    onclick = checked_step,
                    disabled = if (activeButton() == "achievements") TRUE else NULL
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
    
    # Open modal to ask for confirmation before deleting goal
    observeEvent(input$delete_goal, {
      goal_id <- input$delete_goal
      
      showModal(
        modalDialog(
          title = "Confirm Deletion",
          "⚠️ Are you sure you want to delete this goal? This action cannot be undone.",
          footer = tagList(
            modalButton("Cancel"),
            actionButton(
              ns("confirm_delete"),
              "Delete",
              class = "btn-danger"
            )
          ),
          easyClose = TRUE
        )
      )
      
      observeEvent(input$confirm_delete, {
        removeModal()
        
        tryCatch({
          delete_goal(conn, goal_id)
          refresh()
          showNotification("Goal deleted successfully", type = "message")
          
          progress_refresh()
          
        }, error = function(e) {
          showNotification("Failed deleting goal", type = "error")
        })
        
      }, once = TRUE, ignoreInit = TRUE)
    })
    
    observeEvent(input$checked_step, {
      step_id <- input$checked_step
     
      step <- steps()[steps()$step_id == step_id, ]
      
      tryCatch({
        # Update the is_done status of the step
        update_step_status(conn, step$step_id)
        
        # Update the is_completed status of the goal
        # Check if all step was done
        update_goal_status(conn, step$goal_id)
        
        progress_refresh()
        refresh()
        
      }, error = function(e) {
        print(paste("Error updating step:", e$message))
        showNotification("Failed updating step", type = "error")
      })
    })
    
    output$buttons <- renderUI({
      
      div(class = "flex gap-10",
          actionButton(
            ns("active_btn"), 
            "Active", 
            class = paste(
              "px-8 py-3 border text-3xl shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded
     active:scale-95 transition-all duration-150 text-white font-bold hover:bg-[#DDBA7D]",
              ifelse(
                activeButton() == "active",
                "bg-[#CF4B00]",   # active style
                "bg-[#DDBA7D]"    # inactive style
              )
            )
          ),
          
          actionButton(
            ns("achievements_btn"), 
            "Achievements", 
            class = paste(
              "px-8 py-3 border text-3xl shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded
     active:scale-95 transition-all duration-150 text-white font-bold hover:bg-[#DDBA7D]",
              ifelse(
                activeButton() == "achievements",
                "bg-[#CF4B00]",   # active style
                "bg-[#DDBA7D]"    # inactive style
              )
            )
          )
          
      )
    })
    
    
    observeEvent(input$active_btn, {
      activeButton("active")
      print("Active Clicked")
    })
    
    observeEvent(input$achievements_btn, {
      activeButton("achievements")
      print("Achievements Clicked")
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
 
    
 