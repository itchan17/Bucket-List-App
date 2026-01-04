loginUI <- function(id) {
  ns <- NS(id)
  
  div(
    class = "w-full h-screen flex items-center justify-center border border-black",
    div(
      class = "rounded-lg shadow-[4px_4px_0px_8px_rgba(0,_0,_0,_0.8)] p-8 max-w-[500px] w-full mx-4 bg-[#FCF6D9] space-y-5",
      
      div(
        class = "flex justify-center mb-6",
        h2("User Login", class = "text-5xl font-bold"),
      ),
      
      div(
        tags$label("Username", `for` = "goal_title", class = "font-bold mb-2"),
        tags$input(
          type = "text",
          id = ns("username"),
          class = "w-full border border-black px-4 py-2 rounded h-16  text-2xl bg-[#FCF6D9]",
        )
      ),
      
      div(
        tags$label("Password", `for` = "goal_title", class = "font-bold mb-2"),
        tags$input(
          type = "password",
          id = ns("password"),
          class = "w-full border border-black px-4 py-2 rounded h-16  text-2xl bg-[#FCF6D9] mb-5",
        )
      ),
      
      actionButton(
        ns("login_btn"),
        "Login",
        class = "px-6 py-3 border-2 border-black rounded shadow-[2px_2px_0px_2px_rgba(0,_0,_0,_0.8)]
          active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D] w-full"
      )
      
    )
  )
 
}