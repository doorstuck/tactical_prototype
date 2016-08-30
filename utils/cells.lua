function get_cell_coordinates(cell_x, cell_y)
  -- cell_size + 1 pixel for border for each cell + 1 pixel after the final border
  x1 = cell_x * (cell_size + 1) + 1
  y1 = cell_y * (cell_size + 1) + 1
  -- taking inner point, that's why it's -1
  x2 = (cell_x + 1) * (cell_size + 1) - 1
  y2 = (cell_y + 1) * (cell_size + 1) - 1
  return x1, y1, x2, y2
end

function get_cell_in(x, y)
  cell_x = math.floor(x / (cell_size + 1))
  cell_y = math.floor(y / (cell_size + 1))
  return cell_x, cell_y  
end

function get_distance_to_cell(origin_x, origin_y, dest_cell_x, dest_cell_y)
  x1, y1, x2, y = get_cell_coordinates(dest_cell_x, dest_cell_y)
  dx = origin_x - x1
  dy = origin_y - y1
  return math.floor(math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)))
end
