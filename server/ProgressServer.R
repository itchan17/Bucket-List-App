# Function used to passed in the MainLayout to display the progress
progressDisplayUI <- function(id) {
  ns <- NS(id)
  
  # This displays the progress
  uiOutput(ns("display_progress"),
     
                 class = "shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] rounded-lg col-span-2 row-span-1 flex items-center px-20 py-10 h-full space-x-10")  
}

profileDisplayDetailsUI <- function(id) {
  ns <- NS(id)
  
  # This displays the progress
  uiOutput(ns("display_profile_details"))  
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
    
    profileImagePath <- reactiveVal(get_profile_image(conn))
    
    
    output$display_progress <- renderUI({
      
      refresh_trigger()
      
      xp_data <- calculate_xp(conn)
      
      current_xp <- sum(xp_data$total_xp)
      
      progress_details <- set_progress_details(current_xp) 
      
      tagList(
          
        # File input for profile image
        tags$div(
          class = "absolute w-0 h-0 overflow-hidden opacity-0",
          fileInput(
            inputId = ns("profile_upload"),
            label = NULL, 
            accept = "image/*"
          )
        ),
        
        # Profile image
        div(
          class = "relative w-[80px] h-[80px] rounded-lg shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] shrink-0 cursor-pointer active:scale-95",
          onclick = "openProfileModal()",
          
          tags$img(
            src = profileImagePath(),
            alt = "Profile Image",
            class = "w-full h-full object-cover"
          ),
          
          tags$label(
            `for` = ns("profile_upload"),
            class = "absolute -top-3 -right-5 w-[30px] h-[30px] bg-[#CF4B00] rounded-full border-0 cursor-pointer active:scale-95 flex items-center justify-center",
            onclick = "event.stopPropagation();",
            tags$i(class = "fa-solid fa-pencil text-[#FCF6D9] text-lg")
          )
        ),
        
      
        
          div(
            class = "w-full",
             div(
               class = "flex items-center",
               tags$img(
                 src = progress_details$badge,
                 alt = progress_details$level,
                 class = "w-[130px] h-[70px] rounded-full shrink-0"
               ),
               h1(progress_details$level,
                  class = "text-5xl font-bold mb-5"
               ),
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
    
    # Function that display the details of the profile
    output$display_profile_details <- renderUI({
      
      refresh_trigger()
      
      xp_data <- calculate_xp(conn)
      
      current_xp <- sum(xp_data$total_xp)
      
      progress_details <- set_progress_details(current_xp) 
      
      data <- get_profile_details(conn)
      
      tagList(
        div(
          class = "flex space-x-20",
          
          # Profile image
          div(
            class = " w-[160px] h-[160px] rounded-lg shadow-[2px_2px_0px_5px_rgba(0,_0,_0,_0.8)] shrink-0",
            onclick = "openProfileModal()",
            
            tags$img(
              src = profileImagePath(),
              alt = "Profile Image",
              class = "w-full h-full object-cover"
            ),
          ),
          
          # Details
          div(
            class = "flex space-x-20",
            
            # First column
            div(
              class = "space-y-3",
              div(
                class = "flex items-center space-x-5",
                tags$i(class = "fa-solid fa-trophy text-blue-600 text-5xl"),
                div(
                  h1(
                    class = "text-2xl font-bold",
                    "Total Goals",
                    tags$i(class = "fa-solid fa-check text-green-600 text-2xl")
                  ),
                  span(
                    class = "text-4xl font-black",
                    data$goals_count
                  )
                )
              ),
              div(
                class = "flex items-center space-x-5",
                tags$i(class = "fa-solid fa-medal text-red-600 text-5xl"),
                div(
                  h1(
                    class = "text-2xl font-bold",
                    "Total Steps",
                    tags$i(class = "fa-solid fa-check text-green-600 text-2xl")
                  ),
                  span(
                    class = "text-4xl font-black",
                    data$steps_count
                  )
                )
              )
              
            ),
            
            # Second column
            div(
              class = "space-y-3",
              
              div(
                class = "flex items-center space-x-5",
                tags$i(class = "fa-solid fa-square text-[#CD7F32] text-5xl"),
                div(
                  h1(
                    class = "text-2xl font-bold",
                    "Simple Steps",
                    tags$i(class = "fa-solid fa-check text-green-600 text-2xl")
                  ),
                  span(
                    class = "text-4xl font-black",
                    data$simple_steps_count
                  )
                ),
              ),
              
              div(
                class = "flex items-center space-x-5",
                tags$i(class = "fa-solid fa-diamond text-[#C0C0C0] text-5xl"),
                div(
                  h1(
                    class = "text-2xl font-bold",
                    "Challenge Quests",
                    tags$i(class = "fa-solid fa-check text-green-600 text-2xl")
                  ),
                  span(
                    class = "text-4xl font-black",
                    data$challenge_quests_count
                  )
                ),
              ),
              
              div(
                class = "flex items-center space-x-5",
                tags$i(class = "fa-solid fa-star text-[#FFD700] text-5xl"),
                div(
                  h1(
                    class = "text-2xl font-bold",
                    "Epic Achievements",
                    tags$i(class = "fa-solid fa-check text-green-600 text-2xl")
                  ),
                  span(
                    class = "text-4xl font-black",
                    data$epic_achievements_count
                  )
                )
              )
              
            ),
          ),
        ),
        # Badge
        div(
          class = "flex flex-col justify-center items-center w-full",
          tags$img(
            src = progress_details$badge,
            alt = progress_details$level,
            class = "w-160 h-160 rounded-full shrink-0 float",
          ),
          h1(progress_details$level,
             class = "text-6xl font-black italic mb-5"
          ),
        ),
       
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
          class = "flex flex-col h-full items-center",
        
            
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
    
    
    data_file <- eventReactive(input$profile_upload, {
      req(input$profile_upload) # Ensure a file is actually uploaded
      
    
    })
    
    observeEvent(input$profile_upload, {
       req(input$profile_upload)
      
       file_data <- input$profile_upload
      
       file_path <- paste0("images/profile_images/", file_data$name)
       file_name <- file_data$name
       
      # Example: save permanently
       file.copy(
         from = file_data$datapath,
         to = file.path("www/images/profile_images", file_data$name),
         overwrite = TRUE
       )
    
       profileImageData <- upload_profile_image(conn, file_name, file_path)
       
       profileImagePath(profileImageData)
    })
    
    
    return(list(
      refresh = refresh
    )
    
    )
    
    
      
  })
}