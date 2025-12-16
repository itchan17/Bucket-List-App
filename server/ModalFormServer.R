modalFormServer <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive values
    steps <- reactiveVal(character(0))
    indexToEdit <- reactiveVal(NULL)
    difficulty <- reactive({
      n <- length(steps())
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
    
    
    output$add_step_button  <- renderUI({
      button_text <- if (!is.null(indexToEdit())) "Save" else "Add"
      
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
      new_step <- input$goal_step
      current_steps <- steps()
     
      
      if (new_step != "") {
        if(!is.null(indexToEdit())){
          current_steps[indexToEdit()] <- new_step
          steps(current_steps)
          indexToEdit(NULL)
        }
        else {
          # Append new step to existing steps
          steps(c(current_steps, new_step))
        }
        
        # Clear the input for next step
        updateTextInput(session, "goal_step", value = "")
        
       
      }
    })
    
    # List added steps
    output$current_steps <- renderUI({
      current_steps <- steps()
      
      tagList(
        lapply(seq_along(current_steps), function(i) {
          div(
            class = "px-6 py-4 hover:bg-[#DDBA7D] rounded flex justify-between items-center active:scale-95 transition-all duration-300",
            span(current_steps[i], class = "text-3xl"),
            div(
              class = "flex gap-5",
              # Edit icon
              tags$button(
                icon("fa-solid fa-pen-to-square", class = "text-[#CF4B00] text-4xl"),
                class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("edit_step"), i)
              ),
              # Delete icon
              tags$button(
                icon("fa-solid fa-x", class = "text-[#CF4B00] text-4xl"),
                class = "bg-transparent border-0 cursor-pointer hover:opacity-70",
                onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("delete_step"), i)
              )
            )
          )
        })
      )
    })
    
    # Handle delete
    observeEvent(input$delete_step, {
      current_steps <- steps()
      if (input$delete_step <= length(current_steps)) {
        steps(current_steps[-input$delete_step])
        
        # Clear the data to edit if  user tries to delete
        # step that is currently on edit
        indexToEdit(NULL)
        updateTextInput(session, "goal_step", value = "")
      }
    })
    
   
    # Handle edit
    observeEvent(input$edit_step, {
      current_steps <- steps()
      if (input$edit_step <= length(current_steps)) {
       
        # Pre-fill the input
        session$sendInputMessage("goal_step", list(value = current_steps[input$edit_step]))
        
        # Get the index of dataa to edit
        indexToEdit(input$edit_step) 
       
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
    }
    
    observeEvent(input$modal_closed, {
      clear_data()
    })
    
    # Handles saving the goal
    observeEvent(input$save_goal, {
      goal_title <- input$goal_title
      goal_category <- input$goal_category
      
      # Validate inputs
      if (is.null(goal_title) || goal_title == "") {
        showNotification("Please enter a goal title", type = "error")
        return()
      }
      
      if (is.null(goal_category) || goal_category == "") {
        showNotification("Please select a category", type = "error")
        return()
      }
      
      if (length(steps()) == 0) {
        showNotification("Please add at least one step", type = "error")
        return()
      }
      
      tryCatch({
        goal_id <- insert_goal(conn, goal_title, goal_title, difficulty())
        insert_steps(conn, goal_id, steps())
        
        # Clear inputs
        clear_data()
        
        # Close the modal
        runjs("closeModal();")
        
      }, error = function(e) {
        showNotification(paste("Error saving goal:", e$message), type = "error")
      })
    })
    
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
    
    # handle query for inserting stepps  in table
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
    
    
  })
}
