cell_size = 40
ui_size = 200
vertical_cells = 20
horizontal_cells = 20

-- cells + lines (-1 because 1 less line at the top)
screen_width = (cell_size + 1) * vertical_cells - 1
screen_height = screen_width + ui_size


background_width = screen_width
background_height = screen_width