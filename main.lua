require "globals"
require "utils/cells"
require "characters/char_base"
require "map/map"
require "map/map_point"
require "utils/log"
require "ui"
require "skills/melee_strike"

map = nil

function create_test_chars()
  local chars = {}
  local char = CharacterBase.new(5, 5, 'assets/characters/char.png')
  local char_2 = CharacterBase.new(10, 5, 'assets/characters/char.png')
  local char_3 = CharacterBase.new(7, 7, 'assets/characters/char.png')
  char_2.is_player_controlled = false
  char.skills = {}
  table.insert(char.skills, Skills.Active.MeleeStrike.new())
  table.insert(chars, char)
  table.insert(chars, char_2)
  table.insert(chars, char_3)
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
  
  UI.MousePressed(x, y, map)
  
end

function CharFinishedMove()
  UI.EnableControl()
end
