compute_effective_dimension <- function(room_dim, buffer1, buffer2, pupil_clearance = 0) {
  room_dim - buffer1 - buffer2 - pupil_clearance
}


compute_desk_count <- function(min_separation, room_dim, desk_dim) {
  pupil_unit  <- desk_dim + min_separation
  extra_space <- room_dim %% pupil_unit
  pupil_count <- room_dim / pupil_unit
  
  desk_count <- if(extra_space >= desk_dim) ceiling(pupil_count) else floor(pupil_count)
  
  desk_count
}


compute_edge_to_edge_separation <- function(desk_count, room_dim, desk_dim) {
  (room_dim - desk_dim * desk_count) / (desk_count - 1)
}



build_buffer_geom_rect_data <- function(front, rear, left, right, room_w, room_d, pupil) {
  coords_left <-  c(xmin = 0,
                    ymin = 0,
                    xmax = left,
                    ymax = room_d)
  coords_right <- c(xmin = room_w - right,
                    ymin = 0,
                    xmax = room_w,
                    ymax = room_d)
  coords_front <- c(xmin = coords_left["xmax"],
                    ymin = room_d - front,
                    xmax = coords_right["xmin"],
                    ymax = room_d)
  coords_rear <-  c(xmin = coords_left["xmax"],
                    ymin = 0,
                    xmax = coords_right["xmin"],
                    ymax = rear)
  coords_pupil <- c(xmin = left,
                    ymin = rear,
                    xmax = room_w - right,
                    ymax = rear + pupil)
  
  coord_list <- list(left  = coords_left,
                     rear  = coords_rear,
                     right = coords_right,
                     front = coords_front,
                     pupil = coords_pupil)
  
  coord_data <- as.data.frame(do.call(rbind, coord_list))
  coord_data
}


build_naive_grid_vector <- function(desk_count, room_dim, desk_dim) {
  separation      <- compute_edge_to_edge_separation(desk_count, room_dim, desk_dim)
  pupil_unit      <- desk_dim + separation
  zeroed_points   <- seq(from = 0, to = pupil_unit * (desk_count - 1), by = pupil_unit)
  adjusted_points <- zeroed_points + (desk_dim / 2)
  
  adjusted_points
}


build_desk_geom_tile_data <- function(buffer_data, desk_count_w, desk_count_d, desk_w, desk_d) {
  width_grid_row    <- build_naive_grid_vector(desk_count_w,
                                               buffer_data["right", "xmin"] - buffer_data["left", "xmax"],
                                               desk_w)
  width_grid_adjust <- width_grid_row + buffer_data["left", "xmax"]
  
  depth_grid_row    <- build_naive_grid_vector(desk_count_d,
                                               buffer_data["front", "ymin"] - buffer_data["pupil", "ymax"],
                                               desk_d)
  depth_grid_adjust <- depth_grid_row + buffer_data["pupil", "ymax"]
  
  buffer_data   <- setNames(expand.grid(width_grid_adjust, depth_grid_adjust),
                            c("x", "y"))
  buffer_data$w <- desk_w
  buffer_data$d <- desk_d
  
  buffer_data
}


build_blackboard_geom_rect_data <- function(buffer_data, desk_width) {
  data.frame(xmin = buffer_data["left", "xmax"] + desk_width,
             xmax = buffer_data["right", "xmin"] - desk_width,
             ymin = buffer_data["front", "ymax"],
             ymax = buffer_data["front", "ymax"] + 0.5)
}


build_tick_data <- function(tile_vector, desk_dim) {
  breaks    <- c(0, unique(tile_vector) + (desk_dim) / 2)
  tick_data <- data.frame(breaks = breaks,
                          labels = pretty_print_feet(breaks))
  
  tick_data
}


pretty_print_feet <- function(feet_numeric) {
  feet_round <- round(feet_numeric, 4)
  feet   <- floor(feet_round)
  inches <- round((feet_round - feet) * 12, 1)
  pretty <- paste0(feet, "' ", inches, '"')
  
  pretty
}



plot_classroom <- function(buffer_front, buffer_rear, buffer_left, buffer_right,
                           pupil_clearance, desk_width, desk_depth,
                           room_width, room_depth,
                           room_number,
                           min_desk_separation = 6) {
  
  effective_w <- compute_effective_dimension(room_dim = room_width,
                                             buffer1  = buffer_left,
                                             buffer2  = buffer_right)
  effective_d <- compute_effective_dimension(room_dim = room_depth,
                                             buffer1  = buffer_front,
                                             buffer2  = buffer_rear,
                                             pupil_clearance = pupil_clearance)
  
  desk_count_w <- compute_desk_count(min_separation = min_desk_separation,
                                     room_dim = effective_w,
                                     desk_dim = desk_width)
  desk_count_d <- compute_desk_count(min_separation = min_desk_separation,
                                     room_dim = effective_d,
                                     desk_dim = desk_depth)
  
  
  buffer_data <- build_buffer_geom_rect_data(front  = buffer_front,
                                             rear   = buffer_rear,
                                             left   = buffer_left,
                                             right  = buffer_right,
                                             room_w = room_width,
                                             room_d = room_depth,
                                             pupil  = pupil_clearance)
  
  desk_tile_data <- build_desk_geom_tile_data(buffer_data    = buffer_data,
                                              desk_count_w   = desk_count_w,
                                              desk_count_d   = desk_count_d,
                                              desk_w         = desk_width,
                                              desk_d         = desk_depth)
  
  ticks_x <- build_tick_data(desk_tile_data$x, desk_width)
  ticks_y <- build_tick_data(desk_tile_data$y, desk_depth)
  
  
  ggplot() +
    geom_tile(data = desk_tile_data, aes(x = x, y = y, width = w, height = d)) +
    geom_rect(data = buffer_data,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = "gray", alpha = 0.4) +
    geom_rect(data = build_blackboard_geom_rect_data(buffer_data, desk_width),
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = "black") +
    labs(x = "", y = "", title = paste("Room", room_number, "-- Seating for", desk_count_w * desk_count_d)) +
    theme_minimal() +
    theme(panel.grid.minor = element_blank()) +
    scale_x_continuous(breaks = ticks_x$breaks, labels = ticks_x$labels) +
    scale_y_continuous(breaks = ticks_y$breaks, labels = ticks_y$labels)
}
