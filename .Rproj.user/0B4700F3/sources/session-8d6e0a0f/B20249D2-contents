library(shiny)

mainLayout <- function() {
  # Main
  div(
    class = "h-screen flex justify-center items-center p-8",
    
    div(
      class = "w-full lg:max-w-[1200px] h-full shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg  
        p-10 grid grid-cols-2 auto-rows-fr gap-10 bg-[#FCF6D9]",
      
      div(
        class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg col-span-2 row-span-1 flex items-center p-20 h-full",
        
        tags$img(
          src = "images/beginner_explorer.png",   
          alt = "Beginner Expplorer",
          class = "w-60 h-40 rounded-full"  
        ),
        
        div(
          class = "w-full",
          h1("Beginner Explorer",
             class = "text-5xl font-bold mb-5"
          ),
          div(
            class = "w-full bg-[#DDBA7D] relative",
            span(
              "24/49",
              class = "absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 font-bold"
            ),
            div(
              class = "w-full h-10",
              style = paste0("width:", 10, "%; background-color: #CF4B00;")
            )
          )
        )
      ),
      
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
          div(class = "flex gap-10",
              tags$button("Active", class = "px-8 py-3 border text-3xl shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded
                            active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]"),
              tags$button("Achievements", class = "px-8 py-3 border text-3xl shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded
                            active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]")
          )
        ),
        h1("Bucket List", class = "text-4xl font-bold mb-3" ),
        # Goals container 
        div(
          class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 flex-1 flex flex-col overflow-y-auto",
          
          div(
            class = "px-6 py-4 cursor-pointer hover:bg-[#DDBA7D] transform-all duration-300 
              active:scale-95 rounded flex justify-between",
            span(
              "Goal 1",
              class = "text-3xl "
            ),
            div(
              class = "flex gap-5",
              icon("fa-solid fa-pen-to-square", class = "text-[#CF4B00] text-4xl"),
              icon("fa-solid fa-x", class = "text-[#CF4B00] text-4xl"),
            )
          )
        )
      ), # Bucket List Container ---END---
      
      # Details container
      div(
        class = "row-span-4 flex flex-col col-span-2 md:col-span-1",
        h1(
          "Details", 
          class = "text-4xl font-bold mb-3" 
        ),
        div(
          class = "w-full shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 mb-10",
          h2(
            "Category: Travel Goals", 
            class = "text-2xl font-bold" 
          ),
          h2(
            "Difficulty: Epic Achievements", 
            class = "text-2xl font-bold" 
          ),
        ),
        h1(
          "Steps", 
          class = "text-3xl font-bold mb-3" 
        ),
        div(
          class = "w-full shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg p-5 flex-1 flex flex-col overflow-y-auto ",
          div(
            class = "flex items-end space-x-5
              px-6 py-4 hover:bg-[#DDBA7D] transform-all duration-300 rounded",
            
            tags$input(
              type = "checkbox",
              class = "w-9 h-9 accent-[#CF4B00]"
            ),
            
            span(
              "Goal 1",
              class = "text-3xl"
            )
          )
          
        ),
      ), # Details container ---END---
      
    ), # Bucket List Container ---END---
    
  ) # Main ---END---
}