require "globals"
require "utils/cells"
require "characters/char_base"
require "map/map"
require "map/map_point"
require "utils/log"
require "ui"
require "skills/melee_strike"
require "skills/fireball"
require "ai/ai_main"

map = nil
ai = nil
is_player_turn = true
need_ai_move = false
need_ai_hit = false

current_char = {}

function create_test_chars()
  local chars = {}
  local char = CharacterBase.new(5, 5, 'assets/characters/char.png')
  local char_2 = CharacterBase.new(10, 5, 'assets/characters/char.png')
  local char_3 = CharacterBase.new(1, 7, 'assets/characters/char.png')
  char_2.is_player_controlled = false
  table.insert(char.skills, Skills.Active.MeleeStrike.new())
  table.insert(char_2.skills, Skills.Active.MeleeStrike.new())
  table.insert(char_3.skills, Skills.Active.Fireball.new())
  table.insert(chars, char)
  table.insert(chars, char_2)
  table.insert(chars, char_3)
  current_char = char
  return chars
end

function love.load(arg)
  UI.Init(PassTurn)
  
  -- For testing only
  map = Map.new(Map.GenerateCells(horizontal_cells, vertical_cells), create_test_chars(), CharFinishedMove, PassTurn)
  ai = AI.new()
end

function love.update(dt)
  map:MoveChars(dt)
  MakeAIMove()
end

function MakeAIMove()
  if not is_player_turn then

    if need_ai_move then
      target_point = ai:WhereToMoveChar(current_char, map)
      map:MoveChar(current_char, target_point.cell_x, target_point.cell_y)
      need_ai_move = false
    elseif need_ai_hit then
      target_skill, target_point = ai:WhatToAttack(current_char, map)

      if not target_skill or not target_point then
        EndAITurn()
        return
      end
      map:ExcecuteCharSkill(target_skill, target_point.cell_x, target_point.cell_y)
      need_ai_hit = false
      need_ai_move = true
    end
  end
end

function love.draw(dt)
  UI.Draw(map)
end

function PassTurn()
  map:PassTurn()
  
  next_char = map:GetCurrentChar()
  if not current_char.is_player_controlled then
    UI.DisableControl()
    is_player_turn = false
    need_ai_move = true
  else
    UI.EnableControl()
  end
end

function EndAITurn()
  is_player_turn = true
  need_ai_hit = false
  need_ai_move = false
  UI.EnableControl()
end

function love.mousepressed(x, y, button, istouch)
  if (button ~= 1) then
    return
  end 
  
  UI.MousePressed(x, y, map)
  
end

function CharFinishedMove()
  if not is_player_turn then
    need_ai_hit = true
  else
    UI.EnableControl()
  end
end
