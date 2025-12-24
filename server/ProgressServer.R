# Function used to passed in the MainLayout to display the progress
progressDisplayUI <- function(id) {
  ns <- NS(id)
  
  # This displays the progress
  uiOutput(ns("display_progress"),
           class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg col-span-2 row-span-1 flex items-center p-20 h-full")  
}

progressServer <- function(id, conn) {
  moduleServer(id, function(input, output, session) { 
    ns <- session$ns
    
    refresh_trigger <- reactiveVal(0)
    
    levelUpEvent <- reactiveVal(0)
    
    isInitialRender <- reactiveVal(TRUE)
    userProgress <- reactiveValues(
      level = "",
      badge = "",
      current_xp = 0
    )
    
    output$display_progress <- renderUI({
      
      refresh_trigger()
      
      xp_data <- calculate_xp(conn)
      
      current_xp <- sum(xp_data$total_xp)
      
      progress_details <- set_progress_details(current_xp) 
      
      tagList(
       
          
          tags$img(
            src = progress_details$badge,   
            alt = progress_details$level,
            class = "w-80 h-40 rounded-full"  
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
        min_xp <- 0
        level <- "Beginner Explorer"
        badge <- "images/beginner_explorer.png"  
        progress <- (current_xp - min_xp) / (total_xp - min_xp)
        
      } else if(current_xp <= 149) {
        
        total_xp <- 149
        min_xp <- 50
        level <- "Goal Getter"
        badge <- "images/goal_getter.png"   
        progress <- (current_xp - min_xp) / (total_xp - min_xp)
        
      } else if(current_xp <= 299) {
        
        total_xp <- 299
        min_xp <- 150
        level <- "Streak Master"
        badge <- "images/streak_master.png"  
        progress <- (current_xp - min_xp) / (total_xp - min_xp)
        
      } else if(current_xp <= 499) {
        
        total_xp <- 499
        min_xp <- 300
        level <- "Achiever"
        badge <- "images/achiever.png" 
        progress <- (current_xp - min_xp) / (total_xp - min_xp)
      
      } else if(current_xp <= 749) {
        
        total_xp <- 749
        min_xp <- 500
        level <- "Adventurer"
        badge <- "images/adventurer.png"   
        
        
      } else if(current_xp <= 999) {
        
        total_xp <- 999
        min_xp <- 750
        level <- "Skill Builder"
        badge <- "images/skill_builder.png"   
        
      } else if(current_xp >= 1000) {
        
        total_xp <- 1000
        min_xp <- 1000
        level <- "Legend"
        badge <- "images/legend.png"   
        
      }
      
      progress <- (current_xp - min_xp) / (total_xp - min_xp)
      percent <- progress * 100
      
      # Check if user level changes 
      # If true update the userProgress then display the level up overlay
      if(userProgress$level != level){
        
        if (!isInitialRender() && userProgress$current_xp < current_xp) {
          levelUpEvent(levelUpEvent() + 1)
          print(paste("Congratulations you are now", level))
        }
        
        
        # Set the user progress
        userProgress$level <- level
        userProgress$badge <- badge
        userProgress$current_xp <- current_xp
        
        
        isInitialRender(FALSE)
      }
      
      list(total_xp = total_xp, level = level, badge = badge, percent = percent)
    }
    
    refresh <- function() {
      refresh_trigger(refresh_trigger() + 1)
    }
    
    levelUpOverlay <- function(level, badge) {
      print("LEVEL UP OVERLAY")
      div(
        id = "levelup-overlay",
        class = "fixed z-[1000] w-full h-full top-0 left-0 bg-black/80 flex justify-center items-center transition-all duration-300",
        
        
        div(
          class = "flex flex-col h-full justify-center items-center",
        
            
          # Badge image
          div(
            class = "rounded-full w-[800px] h-[450px]",
            tags$img(
              src = badge,
              alt = level,
              class = "w-full h-full rounded-full"
            )
          ),
          
          
          h1(HTML(paste0("🎉 Congratulations! 🎉")), class = "text-6xl font-bold italic text-white mb-5"),
          h1("You’ve just leveled up to:", class = "text-5xl font-bold italic text-white"),
          h1(HTML(paste("💎 ", level ," 💎")), class = "text-6xl font-bold italic text-white mb-5"),
          h1("Keep up the streak and collect more badges!", class = "text-5xl font-bold italic text-white mb-10"),
          
          actionButton(
            ns("close_level_up"),
            "Continue",
            class = "px-8 py-3 border text-3xl shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] 
              rounded active:scale-95 transition-all duration-150 bg-[#CF4B00] text-white font-bold hover:bg-[#DDBA7D]",
          )
        )
      )
      
      
    }
    
    observeEvent(levelUpEvent(), {
      
     if(levelUpEvent() > 0) {
       insertUI(
         selector = "body",
         where = "beforeEnd",
         ui = levelUpOverlay(userProgress$level, userProgress$badge)
       )
     }
    })
    
    observeEvent(input$close_level_up, {
      
      removeUI(selector = "#levelup-overlay")
      
    })
    
    
    return(list(
      refresh = refresh
    )
    
    )
    
    
      
  })
}