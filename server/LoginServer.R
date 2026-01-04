loginServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  
    isLoggedIn  <- reactiveVal(FALSE)
    
    observeEvent(input$restore_session, {
      isLoggedIn(TRUE)
    }, once = TRUE)
    
    observeEvent(input$login_btn, {
      user <- "user"
      password <- "password123"
      
      if(input$username == user && input$password == password){
        updateTextInput(session, "username", value = "")
        updateTextInput(session, "password", value = "")
        runjs("localStorage.setItem('loggedIn', 'true');")
        isLoggedIn(TRUE)
      } else {
        showNotification("Invalid login credentials. Please try again.", type = "error")
      }
     
    })
    
    return(list(
      isLoggedIn = isLoggedIn
    ))
    
  })
}
