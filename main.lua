require "globals"
require "utils/cells"
require "characters/char_base"
require "map/map"
require "map/map_point"
require "utils/log"
require "ui"

selected_char = nil
map = nil

function create_test_chars()
  local chars = {}
  local char = CharacterBase.new(5, 5, 'assets/characters/char.png')
  table.insert(chars, char)
  return chars
end

function love.load(arg)
  UI.Init()
  
  -- For testing only
  map = Map.new(Map.GenerateCells(horizontal_cells, vertical_cells), create_test_chars(), CharFinishedMove)
end

function love.update(dt)
  map:MoveChars(dt)
end

function love.draw(dt)
  UI.Draw(map)
end

function love.mousepressed(x, y, button, istouch)
  if (button ~= 1) then
    return
  end 
  
  cell_x, cell_y = get_cell_in(x, y)

  if (selected_char) then
    -- Selected char is pressed - deselect.
    if selected_char.cell_x == cell_x and selected_char.cell_y == cell_y then
      selected_char = nil
      UI.UnselectChar()
    -- char is selected but other point is pressed.
    else
      char_on_place = map:GetChar(cell_x, cell_y)
      -- another char is selected.
      if char_on_place then
        selected_char = char_on_place
        UI.SelectChar(char_on_place)
      elseif CharCanMoveThere(selected_char, map, cell_x, cell_y) then
        map:MoveChar(char, cell_x, cell_y)
        UI.UnselectChar()
        UI.DisableControl()
      end 
    end
  else
    -- No char is selected - the only thing we can do here is select a char on this spot.
    char_on_place = map:GetChar(cell_x, cell_y)
    if char_on_place then
      UI.SelectChar(char_on_place)
      selected_char = char_on_place
    end
  end
end

function CharFinishedMove()
  UI.EnableControl()
end

function CharCanMoveThere(char, map, cell_x, cell_y)
  local reachable_points = map:GetCharMoveblePoints(char.cell_x, char.cell_y)
  if not reachable_points then return end
  return reachable_points[MapPoint.CalculateHash(cell_x, cell_y)]
end
