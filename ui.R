source("helpers.R")
library(ggplot2)

ui <- fluidPage(
  
  # App title ----
  titlePanel("Classroom Planner:  Enter Dimensions in Feet"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
  
      textInput(inputId = "room_number",
                label = "Room number",
                value = NULL),
      
      numericInput(inputId = "min_desk_separation",
                   label = "Minimum separation between desks",
                   value = 6,
                   min   = 0),
      
      numericInput(inputId = "room_depth",
                   label = "Room depth (front to back as seen by student)",
                   value = 40,
                   min   = 1),
      
      numericInput(inputId = "room_width",
                   label = "Room width (left to right as seen by student)",
                   value = 30,
                   min   = 1),
      
      numericInput(inputId = "buffer_front",
                   label = "Buffer zone in front",
                   value = 8),
      
      numericInput(inputId = "buffer_rear",
                   label = "Buffer zone in back",
                   value = 0),
      
      numericInput(inputId = "buffer_left",
                   label = "Buffer zone on left",
                   value = 0),
      
      numericInput(inputId = "buffer_right",
                   label = "Buffer zone on right",
                   value = 0),
      
      numericInput(inputId = "desk_depth",
                   label = "Desk depth (top surface, front to back)",
                   value = 2),
      
      numericInput(inputId = "desk_width",
                   label = "Desk width (top surface, left to right)",
                   value = 2),
      
      numericInput(inputId = "pupil_clearance",
                   label = "Clearance required for pupil at desk",
                   value = 3)
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      plotOutput("classroom_map")
      
    )
  )
)