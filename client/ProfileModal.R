library(shiny)

profileModalUI <- function(id, profile_details = NULL) {
  ns <- NS(id) 
  div(
    id = "profileModal",
    class = "fixed z-[1000] w-full h-full top-0 left-0 bg-black/50 flex justify-center items-center 
    opacity-0 invisible transition-all duration-300",
    onclick = "if(event.target === this) closeProfileModal()",
    
    div(
      class = "rounded-lg shadow-[4px_4px_0px_8px_rgba(0,_0,_0,_0.8)] p-8 max-w-[700px] w-full mx-4 bg-[#FCF6D9]",
      
      # Modal Header
      div(
        class = "flex justify-between items-center mb-6",
        h2("Profile", class = "text-3xl font-bold"),
        tags$button(
          "×",
          onclick = "closeProfileModal()",
          class = "text-4xl font-bold hover:text-gray-600 leading-none"
        ),
      ),
      
      # Modal Body
      div(
       
        class = "mb-6 flex flex-col",
       
        # Modal content here
        profile_details
        
      ),
    )
  )
}

# Modal JavaScript
profileModalFormJS <- function() {
  tags$script(HTML("
    function openProfileModal() {
      const modal = document.getElementById('profileModal');
      modal.classList.remove('invisible', 'opacity-0');
      modal.classList.add('opacity-100');
    }
    
    function closeProfileModal() {
      const modal = document.getElementById('profileModal');
      modal.classList.remove('opacity-100');
      modal.classList.add('invisible', 'opacity-0');
      
      // Use single quotes for 'event' instead of double quotes
      // Shiny.setInputValue('goalModal-modal_closed', true, {priority: 'event'});
    }
  "))
}


