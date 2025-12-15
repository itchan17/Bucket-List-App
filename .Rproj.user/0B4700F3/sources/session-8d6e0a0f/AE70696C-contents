library(shiny)

modalFormUI <- function() {
  div(
    id = "customModal",
    class = "fixed z-[1000] w-full h-full top-0 left-0 bg-black/50 flex hidden justify-center items-center",
    onclick = "if(event.target === this) closeModal()",
    
    div(
      class = "rounded-lg shadow-[4px_4px_0px_8px_rgba(0,_0,_0,_0.8)] p-8 max-w-[700px] w-full mx-4 bg-[#FCF6D9]",
      
      # Modal Header
      div(
        class = "flex justify-between items-center mb-6",
        h2("Add New Goal", class = "text-3xl font-bold"),
        tags$button(
          "×",
          onclick = "closeModal()",
          class = "text-4xl font-bold hover:text-gray-600 leading-none"
        )
      ),
      
      # Modal Body
      div(
        class = "space-y-5 mb-6",
        div(
         tags$label("Goal title", `for` = "goal_name", class = "font-bold mb-2"),
         tags$input(
           type = "text",
           id = "goal_name",
           class = "w-full border border-black px-4 py-2 rounded h-16  text-2xl bg-[#FCF6D9]",
         )
        ),
        
        div(
          class = "mb-4",
          tags$label("Category", `for` = "goal_category", class = "font-bold mb-2"),
          tags$select(
            id = "goal_category",
            class = "w-full border border-black px-4 py-2 rounded h-16 cursor-pointer bg-[#FCF6D9]",
            tags$option(value = "", "Select a category..."),
            tags$option(value = "travel", "Travel Goals"),
            tags$option(value = "career", "Career Goals"),
            tags$option(value = "health", "Health Goals"),
            tags$option(value = "learning", "Learning Goals"),
            tags$option(value = "personal", "Personal Development"),
            tags$option(value = "relationship", "Relationship Goals")
          )
        ),
        
        div(
          class = "flex items-end gap-5",
          div(
            class = "flex-1",
            tags$label("Add steps", `for` = "goal_name", class = "font-bold mb-2"),
            tags$input(
              type = "text",
              id = "goal_name",
              class = "w-full border border-black px-4 py-2 rounded h-16  text-2xl bg-[#FCF6D9]",
            )
          ),
          tags$button(
            "Add",
            class = "px-6 py-2 border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)] h-16
            active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]"
          ),
        ),
        
        div(
          h1("Current steps", class = "font-bold mb-4" ),
          div(
            class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 flex-1 flex flex-col overflow-y-auto h-60 overflow-y-auto",
            
            div(
              class = "px-6 py-4 cursor-pointer hover:bg-[#DDBA7D] transform-all duration-300 
              active:scale-95 rounded flex justify-between",
              span(
                "Step 1",
                class = "text-3xl "
              ),
              div(
                class = "flex gap-5",
                icon("fa-solid fa-pen-to-square", class = "text-[#CF4B00] text-4xl"),
                icon("fa-solid fa-x", class = "text-[#CF4B00] text-4xl"),
              )
            )
          )
        ),
        
        h1("Difficulty: Epic Achievements", class = "text-3xl font-bold mb-4" ),
      ),
      
      # Modal Footer
      div(
        class = "flex gap-4 justify-end",
        tags$button(
          "Cancel",
          onclick = "closeModal()",
          class = "px-6 py-2 border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)]
          active:scale-95 transition-all duration-150"
        ),
        actionButton(
          "save_goal",
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
      modal.classList.remove('hidden')
      modal.classList.add('flex')
    }
    
    function closeModal() {
      const modal = document.getElementById('customModal');
      modal.classList.remove('flex')
      modal.classList.add('hidden')
    }
  "))
}


