library(shiny)

mainLayout <- function(id, list_goals, display_details, goalButtons, display_progress) {
  ns <- NS(id) 
  # Main
  div(
    class = "h-screen flex justify-center items-start p-8",
    
    div(
      class = "w-full lg:max-w-[1200px] h-full shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg  
        p-10 grid grid-cols-2 auto-rows-fr gap-10 bg-[#FCF6D9]",
      
      # Display progress here
      display_progress,
      
      # Bucket List Container
      div(
        class = "rounded-lg col-span-2 md:col-span-1 row-span-4 flex flex-col rounded-lg",
        
        # Buttons container
        div(
          class = "flex items-center justify-between mb-10",
          tags$button(
            "Add New Goal", 
            class = "px-8 py-3 border text-3xl shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] 
              rounded active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]",
            onCLick =  "openModal()"
          ),
          goalButtons
        ),
        h1("Bucket List", class = "text-4xl font-bold mb-3" ),
        # Goals container 
        div(
          class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 flex-1 flex flex-col overflow-y-auto",
          
         # List goals here
         list_goals
        )
      ), # Bucket List Container ---END---
      
      # Details container
      
      display_details,
     
      # Details container ---END---
      
    ), # Bucket List Container ---END---
    
    div(
      class = "pl-10",
      actionButton(
        ns("logout_btn"),
        "Logout",
        class = "border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)]
          active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]"
      )
    )
    
  ) # Main ---END---
}