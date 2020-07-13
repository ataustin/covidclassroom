server <- function(input, output) {
  output$classroom_map <-
    plot_classroom(buffer_front = input$buffer_front,
                   buffer_rear  = input$buffer_rear,
                   buffer_left  = input$buffer_left,
                   buffer_right = input$buffer_right,
                   pupil_clearance = input$pupil_clearance,
                   desk_width      = input$desk_width,
                   desk_depth      = input$desk_depth,
                   room_width      = input$room_width,
                   room_depth      = input$room_depth,
                   room_number     = input$room_number,
                   min_desk_separation = input$min_desk_separation)
}