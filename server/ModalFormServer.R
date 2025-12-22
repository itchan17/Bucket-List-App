modalFormServer <- function(id, conn, refresh) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive values
    steps <- reactiveVal(character(0))
    indexToEdit <- reactiveVal(NULL)
    goalIdToUpdate <- reactiveVal(NULL)
    
    difficulty <- reactive({
     
      # Check for the value of goalIdToUpdate
      # If not null it means its for edit
      if(is.null(goalIdToUpdate())) {
        n <- length(steps())
      } else {
        # We will count  the row of editingSteps which is a data frame
        n <- nrow(editingSteps())
      }
      
      if (n == 0) {
        return("")
      } else if (n <= 3) {
        return("Simple Steps")
      } else if (n <= 6) {
        return("Challenge Quests")
      } else {
        return("Epic Achievements")
      }
    })
    
    # Variable that store steps when editing
    editingSteps <- reactiveVal(data.frame(
      step_id = integer(0),
      title = character(0)
    ))
    stepIdToUpdate <- reactiveVal(NULL)
    
    
    output$add_step_button  <- renderUI({
      button_text <- if (!is.null(indexToEdit()) || !is.null(stepIdToUpdate())) "Save" else "Add"
      
      actionButton(
        ns("add_step"),
        button_text,
        class = "px-6 py-2 border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)] h-16
        active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]"
      )
    })
    
    
    # Add steps

    observeEvent(input$add_step, {
      print("Add step button clicked!")
      step <- input$goal_step
      current_steps <- steps()
      
      if (step != "") {
        if(is.null(goalIdToUpdate())) {
          if(!is.null(indexToEdit())){
            current_steps[indexToEdit()] <- step
            steps(current_steps)
            indexToEdit(NULL)
          }
          else {
            # Append new step to existing steps
            steps(c(current_steps, step))
          }
        } else {
          goal_id <-  goalIdToUpdate()
          
          if(!is.null(stepIdToUpdate())){
            # Update the step in the database
            tryCatch({

              update_step(conn, step, stepIdToUpdate())
             
              current_steps = get_all_goal_steps(conn,  goal_id)
              editingSteps(current_steps)
              
            }, error = function(e) {
              print(paste("Error updating step:", e$message))
              showNotification(paste("Error updating step:", e$message), type = "error")
            })
            
            stepIdToUpdate(NULL)
          }
          else {
            # Insert step in the database
            tryCatch({
              
              insert_step(conn, goal_id, step)
              
              current_steps = get_all_goal_steps(conn,  goal_id)
              editingSteps(current_steps)
              
            }, error = function(e) {
              print(paste("Error adding step:", e$message))
              showNotification(paste("Error adding step:", e$message), type = "error")
            })
          }
        }
       
   
        # Clear the input for next step
        updateTextInput(session, "goal_step", value = "")
        
       
      }
    })
    
    # List added steps
    output$current_steps <- renderUI({
      current_steps <- steps()
      
      if(is.null(goalIdToUpdate())) {
        if(length(current_steps) > 0) {
          tagList(
            lapply(seq_along(current_steps), function(i) {
              div(
                class = "px-6 py-4 hover:bg-[#DDBA7D] rounded flex justify-between items-center active:scale-95 transition-all duration-300",
                span(current_steps[i], class = "text-3xl"),
                div(
                  class = "flex gap-5",
                  # Edit button
                  tags$button(
                    icon("fa-solid fa-pen-to-square", class = "text-[#CF4B00] text-4xl"),
                    class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                    onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("edit_step"), i)
                  ),
                  # Delete button
                  tags$button(
                    icon("fa-solid fa-x", class = "text-[#CF4B00] text-4xl"),
                    class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                    onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("delete_step"), i)
                  )
                )
              )
            })
          )
        }
      
      } else {
        currentEditingSteps = editingSteps()
        if(nrow(currentEditingSteps) > 0) {
          tagList(
            lapply(1:nrow(currentEditingSteps), function(i) {
              
              row <- currentEditingSteps[i, ]
              
              div(
                class = "px-6 py-4 hover:bg-[#DDBA7D] rounded flex justify-between items-center active:scale-95 transition-all duration-300",
                span(row$title, class = "text-3xl"),
                div(
                  class = "flex gap-5",
                  # Edit button
                  tags$button(
                    icon("fa-solid fa-pen-to-square", class = "text-[#CF4B00] text-4xl"),
                    class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                    onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("edit_step"), i)
                  ),
                  # Delete button
                  tags$button(
                    icon("fa-solid fa-x", class = "text-[#CF4B00] text-4xl"),
                    class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                    onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("delete_step"), i)
                  )
                )
              )
            })
          )
        }
       
      }
     
    })
    
    # Handle delete
    observeEvent(input$delete_step, {
      print(paste('STEP INDEX: ', input$delete_step))
      if(is.null(goalIdToUpdate())) {
        current_steps <- steps()
      } else {
        current_steps <- editingSteps()
      }
      
      if (input$delete_step <= length(current_steps)) {
        
        if(is.null(goalIdToUpdate())) {
          steps(current_steps[-input$delete_step])
          
          # Clear the data to edit if  user tries to delete
          # step that is currently on edit
          indexToEdit(NULL)
          updateTextInput(session, "goal_step", value = "")
        } else {
          stepId = current_steps[input$delete_step, ]$step_id
          print(paste("DELETE STEP: ", stepId))
          tryCatch({
            
            delete_single_step(conn, stepId)
            
            current_steps = get_all_goal_steps(conn,  goalIdToUpdate())
            editingSteps(current_steps)
            
          }, error = function(e) {
            print(paste("Error deleting step:", e$message))
            showNotification("Failed deleting step", type = "error")
          })
 
        }
      
      }
    })
    
   
    # Handle edit
    observeEvent(input$edit_step, {
     
      if(is.null(goalIdToUpdate())) {
        current_steps <- steps()
      } else {
        current_steps <- editingSteps()
      }
      
      if (input$edit_step <= length(current_steps)) {
       
        title <- if (is.null(goalIdToUpdate())) current_steps[input$edit_step] else current_steps[input$edit_step, "title"]
        # Pre-fill the input
        session$sendInputMessage("goal_step", list(value = title))
        
        # Check if form is on update, if true  we will get the id of step instead of the index
        if (!is.null(goalIdToUpdate())) stepIdToUpdate(current_steps[input$edit_step, ]$step_id) else  indexToEdit(input$edit_step) 
      }
    })
    
    # Display difficulty
    output$difficulty_label <- renderUI({
      h1(paste("Difficulty:", difficulty()), class = "text-3xl font-bold mb-4")
    })
    
    # Clear form data when modal was closed
    clear_data <-  function() {
      updateTextInput(session, "goal_title", value = "")
      updateSelectInput(session, "goal_category", selected = "")
      session$sendInputMessage("goal_step", list(value = ""))
      
      steps(character(0))
      difficulty <- "";
      indexToEdit(NULL)
      
      goalIdToUpdate(NULL) 
      editingSteps(data.frame(
        step_id = integer(0),
        title = character(0)
      ))
      stepIdToUpdate(NULL)
    }
    
    
    observeEvent(input$cancel_goal, {
      runjs("closeModal();")
      clear_data()
    })
    
    # Handles saving the goal
    observeEvent(input$save_goal, {
      goal_title <- input$goal_title
      goal_category <- input$goal_category
      goal_difficulty <- difficulty()
      
      # Validate inputs
      if (is.null(goal_title) || goal_title == "") {
        showNotification("Please enter a goal title", type = "error")
        return()
      }
      
      if (is.null(goal_category) || goal_category == "") {
        showNotification("Please select a category", type = "error")
        return()
      }
      
      stepsCount <- if(is.null(goalIdToUpdate())) length(steps()) else nrow(editingSteps())
      if (stepsCount == 0) {
        showNotification("Please add at least one step", type = "error")
        return()
      }
      
      tryCatch({
        if(is.null(goalIdToUpdate())) {
          
          goal_id <- insert_goal(conn, goal_title, goal_category, goal_difficulty)
          insert_steps(conn, goal_id, steps())
          
        } else {
         
          update_goal(conn, goalIdToUpdate(), goal_title, goal_category, goal_difficulty)
        }
        
        # Clear inputslist_goals
        clear_data()
        
        # Close the modal
        runjs("closeModal();")
        refresh()
        
      }, error = function(e) {
        print(paste("Failed saving goal:", e$message), type = "error")
        showNotification("Failed saving goal", type = "error")
      })
    })
    
    load_goal <- function(goal_id) {
      print(paste("Loading goal:", goal_id))
      
      goalIdToUpdate(goal_id)
      
      tryCatch({
        goal <- get_goal_by_id(conn, goal_id)
        
        # Set the input data
        updateTextInput(session, "goal_title", value = goal$title)
        updateSelectInput(session, "goal_category", selected = goal$category)
        
        current_steps = get_all_goal_steps(conn,  goal_id)
        print(paste("STEPS: ", current_steps));
        editingSteps(current_steps)
        
       
        
      }, error = function(e) {
        print(paste("Error loading goal:", e$message))
        showNotification(paste("Error loading goal:", e$message), type = "error")
      })
    }
 
    return(list(
      load_goal = load_goal
    ))
  
  })
}
