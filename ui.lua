require "map/map_point"

UI = {}
UI.__index = UI

background_img = nil
background_quad = nil

selected_char = nil
move_to_cells = {}

is_controlable = true
is_move_mode = false

function UI.Init()
  love.graphics.setBlendMode("alpha")
  background_img = love.graphics.newImage('assets/background/grass.jpg')
  background_quad = love.graphics.newQuad(0, 0, background_width, background_height, background_img:getDimensions())
end

function UI.Draw(map)
  UI.DrawBackground()
  UI.DrawGrid()
  UI.DrawCharacters(map)
  UI.DrawCharacterMoves(selected_char, map)
  UI.DrawMouseOverSquare()
end

function UI.SelectChar(char)
  selected_char = char
  move_to_cells = nil
end

function UI.UnselectChar()
  selected_char = nil
  move_to_cells = nil
end

function UI.EnableControl()
  is_controlable = false
end

function UI.DisableControl()
  is_controlable = true
end

-- PRIVATE --

function UI.DrawCharacterMoves(char, map)
  if not char then return end
  if not move_to_cells then move_to_cells = map:GetCharMoveblePoints(char.cell_x, char.cell_y) end
  
  for cell_hash, cell_info in pairs(move_to_cells) do
    UI.ColorCell(cell_info.point.cell_x, cell_info.point.cell_y, 0, 0, 150, 100)
  end
end

function UI.DrawGrid()
  love.graphics.setColor(0, 0, 255)
  love.graphics.setLineWidth(1)
  for i = 1, vertical_cells - 1, 1
  do
    love.graphics.line(0, i * (cell_size + 1), background_width, i * (cell_size + 1))
  end
  for i = 1, horizontal_cells - 1, 1
  do
    love.graphics.line(i * (cell_size + 1), 0, i * (cell_size + 1), background_height)
  end
end

function UI.DrawBackground()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(background_img, background_quad, 0, 0)
end

function UI.DrawMouseOverSquare()
  cell_x, cell_y = get_cell_in(love.mouse.getPosition())
  UI.DrawMouseOverChar(cell_x, cell_y)
  UI.DrawMouseOverMovableSquares(cell_x, cell_y)
end

function UI.DrawMouseOverChar()
end

function UI.DrawMouseOverMovableSquares()
end

function UI.DrawCharacters(map)
  map:DrawChars()
end

function UI.ColorSelectedCharCell()
  if (not selected_char) then return end
  UI.ColorCell(selected_char.cell_x, selected_char.cell_y, 150, 0, 0, 100)
end

function UI.ColorCell(cell_x, cell_y, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
end
