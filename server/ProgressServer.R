# Function used to passed in the MainLayout to display the progress
progressDisplayUI <- function(id) {
  ns <- NS(id)
  
  # This displays the progress
  uiOutput(ns("display_progress"),
           class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg col-span-2 row-span-1 flex items-center p-20 h-full")  
}

progressServer <- function(id, conn) {
  moduleServer(id, function(input, output, session) { 
    
    refresh_trigger <- reactiveVal(0)
    
    output$display_progress <- renderUI({
      
      refresh_trigger()
      
      xp_data <- calculate_xp(conn)
      
      current_xp <- sum(xp_data$total_xp)
      
      progress_details <- set_progress_details(current_xp)
      
      print(progress_details)
      
      tagList(
       
          
          tags$img(
            src = progress_details$badge,   
            alt = "Beginner Explorer",
            class = "w-60 h-40 rounded-full"  
          ),
          
          
          div(
            class = "w-full",
            h1(progress_details$level,
               class = "text-5xl font-bold mb-5"
            ),
            div(
              class = "w-full bg-[#DDBA7D] relative",
              span(
                paste(current_xp,"/",progress_details$total_xp),
                class = "absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 font-bold"
              ),
              div(
                class = "w-full h-10",
                style = paste0("width:", progress_details$percent, "%; background-color: #CF4B00;")
              )
            )
          )
      )
    })  
    
    
    set_progress_details <- function(current_xp) {
      if(current_xp <= 49) {
        
        total_xp <- 49
        level <- "Beginner Explorer"
        badge <- "images/beginner_explorer.png"  
        
      } else if(current_xp <= 149) {
        
        total_xp <- 149
        level <- "Goal Getter"
        badge <- "images/goal_getter.png"   
        
      } else if(current_xp <= 299) {
        
        total_xp <- 299
        level <- "Streal Master"
        badge <- "images/streak_master.png"   
        
      } else if(current_xp <= 499) {
        
        total_xp <- 499
        level <- "Achiever"
        badge <- "images/achiever.png"   
      
      } else if(current_xp <= 749) {
        
        total_xp <- 749
        level <- "Adventurer"
        badge <- "images/adventurer.png"   
        
      } else if(current_xp <= 999) {
        
        total_xp <- 999
        level <- "Skill Builder"
        badge <- "images/skill_builder.png"   
        
      } else if(current_xp >= 1000) {
        
        total_xp <- 1000
        level <- "Legend"
        badge <- "images/legend.png"   
        
      }
      
      percent <- (current_xp / total_xp) * 100
      
      list(total_xp = total_xp, level = level, badge = badge, percent = percent)
    }
    
    refresh <- function() {
      refresh_trigger(refresh_trigger() + 1)
    }
    
    return(list(
      refresh = refresh
    )
    
    )
    
    
      
  })
}