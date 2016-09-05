require "globals"
require "utils/cells"
require "characters/char_base"
require "map/map"
require "utils/log"

background_img = nil
background_quad = nil

selected_cells = {}

is_controlable = true

function create_test_chars()
  local chars = {}
  local char = CharacterBase.new(5,5, 'assets/characters/char.png')
  -- char.path = { {["x"] = 3, ["y"] = 4}, {["x"] = 3, ["y"] = 5}, {["x"] = 4, ["y"] = 5}, {["x"] = 5, ["y"] = 5}, {["x"] = 6, ["y"] = 5}, {["x"] = 7, ["y"] = 5}}
  table.insert(chars, char)
  return chars
end

function love.load(arg)
  love.graphics.setBlendMode("alpha")
  background_img = love.graphics.newImage('assets/background/grass.jpg')
  background_quad = love.graphics.newQuad(0, 0, background_width, background_height, background_img:getDimensions())
  
  -- For testing only
  map = Map.new(Map.GenerateCells(horizontal_cells, vertical_cells), create_test_chars())
end

function love.update(dt)
  move_characters(dt)
end

function love.draw(dt)
  draw_background()
  draw_cells()
  draw_characters()
  draw_mouse_over_square()
  draw_selected_cells()
end

function love.mousepressed(x, y, button, istouch)
  if (button ~= 1 or not is_controlable) then
    return
  end 
  cell_x, cell_y = get_cell_in(x, y)

  -- select character
  if (map:GetChar(cell_x, cell_y)) then
    -- select only one charcter at a time
    if is_cell_selected(cell_x, cell_y) then
      toggle_cell(cell_x, cell_y)
    else
      unselect_selected_cells()
      toggle_cell(cell_x, cell_y)
    end
  end
end

function unselect_selected_cells()
  for k in pairs (selected_cells) do
    selected_cells[k] = nil
  end
end

function disable_control()
  is_controlable = false
  love.mouse.setVisible = false
end

function enable_control()
  is_controlable = true
  love.mouse.setVisible = true
end

function draw_characters()
  map:DrawChars()
end

function move_characters(dt)
  map:MoveChars(dt)
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

function draw_mouse_over_square()
  cell_x, cell_y = get_cell_in(love.mouse.getPosition())
  if (not map:GetChar(cell_x, cell_y)) then return end

  love.graphics.setColor(0, 0, 255, 100)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
end

function draw_selected_cells()
  if (not is_controlable) then return end
  for cell_x, y_values in pairs(selected_cells) do
    for cell_y, value in pairs(y_values) do
      draw_selected_cell(cell_x, cell_y)

      -- draw cells that character can move to.
      for cell, prev_path_cell in pairs(map:GetCharMoveblePoints(cell_x, cell_y)) do
        draw_selected_cell(cell.cell_x, cell.cell_y)
      end
    end
  end
end

function draw_selected_cell(cell_x, cell_y)
  love.graphics.setColor(150, 0, 0, 100)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
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
  selected_cells[cell_x][cell_y] = nil
end

function is_cell_selected(cell_x, cell_y)
  return selected_cells and selected_cells[cell_x] and selected_cells[cell_x][cell_y] 
end
