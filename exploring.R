library(ggplot2)


buffer_front <- 6
buffer_rear  <- 2
buffer_left  <- 2
buffer_right <- 0

pupil_clearance <- 3
desk_width      <- 2.5
desk_depth      <- 2

room_width <- 32
room_depth <- 46

min_desk_separation <- 6

room_number <- "123"

x <- plot_classroom(buffer_front, buffer_rear, buffer_left, buffer_right,
               pupil_clearance, desk_width, desk_depth,
               room_width, room_depth,
               room_number,
               min_desk_separation)