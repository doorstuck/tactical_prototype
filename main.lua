require "globals"

background_img = nil
background_quad = nil

selected_cells = {}

function love.load(arg)
  love.graphics.setBlendMode("alpha")
  background_img = love.graphics.newImage('assets/background/grass.jpg')
  background_quad = love.graphics.newQuad(0, 0, background_width, background_height, background_img:getDimensions())
end

function love.update(dt)
end

function love.draw(dt)
  draw_background()
  draw_cells()
  draw_selected_square()
  draw_selected_cells()
end

function draw_background()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(background_img, background_quad, 0, 0)
end

function draw_cells()
  love.graphics.setColor(0, 0, 255)
  love.graphics.setLineWidth(1)
  for i=1,vertical_cells - 1,1
  do
    love.graphics.line(0, i*(cell_size+1), background_width, i*(cell_size+1))
  end
  for i=1,horizontal_cells-1,1
  do
    love.graphics.line(i*(cell_size+1), 0, i*(cell_size+1), background_height)
  end
end

function draw_selected_square()
  cell_x, cell_y = get_cell_in(love.mouse.getPosition())
  love.graphics.setColor(0, 0, 255, 100)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
end

function draw_selected_cells()
  for cell_x, y_values in pairs(selected_cells) do
    for cell_y, value in pairs(y_values) do
      if (value) then
        draw_selected_cell(cell_x, cell_y)
      end
    end
  end
end

function draw_selected_cell(cell_x, cell_y)
  love.graphics.setColor(150, 0, 0, 100)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
end

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

function love.mousepressed(x, y, button, istouch)
  if (button ~= 1) then
    return
  end 
  cell_x, cell_y = get_cell_in(x, y)
  toggle_cell(cell_x, cell_y)
end

function toggle_cell(cell_x, cell_y)
  if is_cell_selected(cell_x, cell_y) then
    unselect_cell(cell_x, cell_y)
  else
    select_cell(cell_x, cell_y)
  end
end

function select_cell(cell_x, cell_y)
  if (not selected_cells[cell_x]) then
    selected_cells[cell_x] = {}
  end
  selected_cells[cell_x][cell_y] = true
end

function unselect_cell(cell_x, cell_y)
  selected_cells[cell_x][cell_y] = false
end

function is_cell_selected(cell_x, cell_y)
  return selected_cells and selected_cells[cell_x] and selected_cells[cell_x][cell_y] 
end
