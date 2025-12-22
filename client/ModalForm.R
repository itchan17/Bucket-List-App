library(shiny)

modalFormUI <- function(id) {
  ns <- NS(id) 
  div(
    id = "customModal",
    class = "fixed z-[1000] w-full h-full top-0 left-0 bg-black/50 flex justify-center items-center 
    opacity-0 invisible transition-all duration-300",
    
    div(
      class = "rounded-lg shadow-[4px_4px_0px_8px_rgba(0,_0,_0,_0.8)] p-8 max-w-[700px] w-full mx-4 bg-[#FCF6D9]",
      
      # Modal Header
      div(
        class = "flex justify-between items-center mb-6",
        h2("Add New Goal", class = "text-3xl font-bold"),
      ),
      
      # Modal Body
      div(
        class = "space-y-5 mb-6",
        div(
          tags$label("Goal title", `for` = "goal_title", class = "font-bold mb-2"),
          tags$input(
            type = "text",
            id = ns("goal_title"),
            class = "w-full border border-black px-4 py-2 rounded h-16  text-2xl bg-[#FCF6D9]",
          )
        ),
        
        div(
          class = "mb-4",
          tags$label("Category", `for` = "goal_category", class = "font-bold mb-2"),
          tags$select(
            id = ns("goal_category"),
            class = "w-full border border-black px-4 py-2 rounded h-16 cursor-pointer bg-[#FCF6D9]",
            tags$option(value = "", "Select a category..."),
            tags$option(value = "Travel Goals", "Travel Goals"),
            tags$option(value = "Career Goals", "Career Goals"),
            tags$option(value = "Health Goals", "Health Goals"),
            tags$option(value = "Learning Goals", "Learning Goals"),
            tags$option(value = "Personal Development", "Personal Development"),
            tags$option(value = "Relationship Goals", "Relationship Goals")
          )
        ),
        
        div(
          class = "flex items-end gap-5",
          div(
            class = "flex-1",
            tags$label("Add steps", `for` = "goal_name", class = "font-bold mb-2"),
            tags$input(
              type = "text",
              id = ns("goal_step"),
              class = "w-full border border-black px-4 py-2 rounded h-16  text-2xl bg-[#FCF6D9]",
            )
          ),
          uiOutput(ns("add_step_button"))
        ),
        
        div(
          h1("Current steps", class = "font-bold mb-4" ),
          div(
            class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 flex-1 flex flex-col overflow-y-auto h-60 overflow-y-auto",
            
            # Steps here
            uiOutput(ns("current_steps"))
          )
        ),
        
       # Difficulty
       uiOutput(ns("difficulty_label"))
      ),
      
      # Modal Footer
      div(
        class = "flex gap-4 justify-end",
        actionButton(
          ns("cancel_goal"),
          "Cancel",
          class = "px-6 py-2 border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)]
          active:scale-95 transition-all duration-150"
        ),
        actionButton(
          ns("save_goal"),
          "Save Goal",
          class = "px-6 py-2 border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)]
          active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]"
        )
      )
    )
  )
}

# Modal JavaScript
modalFormJS <- function() {
  tags$script(HTML("
    function openModal() {
      const modal = document.getElementById('customModal');
      modal.classList.remove('invisible', 'opacity-0');
      modal.classList.add('opacity-100');
    }
    
    function closeModal() {
      const modal = document.getElementById('customModal');
      modal.classList.remove('opacity-100');
      modal.classList.add('invisible', 'opacity-0');
      
      // Use single quotes for 'event' instead of double quotes
      Shiny.setInputValue('goalModal-modal_closed', true, {priority: 'event'});
    }
  "))
}


