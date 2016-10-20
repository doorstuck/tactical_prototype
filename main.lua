require "globals"
require "utils/cells"
require "characters/char_base"
require "map/map"
require "map/map_point"
require "utils/log"
require "ui"
require "skills/melee_strike"
require "skills/fireball"
require "skills/arrow"
require "skills/attack_on_move"
require "skills/retaliate"
require "ai/ai_main"

map = nil
ai = nil
is_player_turn = true
need_ai_move = false
need_ai_hit = false

current_char = {}

function create_test_chars()
  local chars = {}
  local char = CharacterBase.new(5, 5, 'assets/characters/char.png', "Char 1")
  local char_2 = CharacterBase.new(10, 5, 'assets/characters/char.png', "Char 2")
  local char_3 = CharacterBase.new(1, 7, 'assets/characters/char.png', "Char 3")
  char_2.is_player_controlled = false
  local melee_strike = Skills.Active.MeleeStrike.new()
  char.base_skill = melee_strike
  table.insert(char.skills, melee_strike)
  table.insert(char.passive_skills, Skills.Passive.AttackOnMove.new(char))
  table.insert(char.passive_skills, Skills.Passive.Retaliate.new(char))
  table.insert(char_2.skills, Skills.Active.MeleeStrike.new())
  table.insert(char_3.skills, Skills.Active.Fireball.new())
  table.insert(chars, char)
  table.insert(chars, char_3)
  table.insert(chars, char_2)
  current_char = char
  return chars
end

function RegisterPassiveSkills(chars)
  for i, char in pairs(chars) do
    for j, skill in pairs(char.passive_skills) do
      skill:Register(map, char)
    end
  end
end

function love.load(arg)
  UI.Init(EndTurnButtonPressed, CharFinishedAttack)
  
  -- For testing only
  local test_chars = create_test_chars()
  map = Map.new(Map.GenerateCells(horizontal_cells, vertical_cells), test_chars, CharFinishedMove, PassTurn)
  RegisterPassiveSkills(test_chars)
  ai = AI.new()
  UI.SelectChar(map:GetCurrentChar())
end

function love.update(dt)
  map:MoveChars(dt)
  UI.Update(dt)
  MakeAIMove()
end

function MakeAIMove()
  if not is_player_turn then

    if need_ai_move then
      LogDebug("Asking for a move from AI")
      local target_point = ai:WhereToMove(current_char, map)
      if target_point then
        LogDebug("Received move to point from AI: " ..target_point:ToString())
        map:MoveChar(current_char, target_point.cell_x, target_point.cell_y)
      else
        LogDebug("No move received from AI, passing to hit")
        need_ai_hit = true
      end

      need_ai_move = false
    elseif need_ai_hit then
      LogDebug("Asking for a hit from AI")
      local target_skill, target_point = ai:WhatToAttack(current_char, map)

      if not target_skill or not target_point then
        LogDebug("Not hit received from AI. Passing turn.")
        EndAITurn()
        return
      end

      LogDebug("Received attack point from AI: " .. target_point:ToString())

      UI.ExecuteCharSkill(current_char, target_point.cell_x, target_point.cell_y, target_skill)
      need_ai_hit = false
      need_ai_move = false
    end
  end
end

function love.draw()
  UI.Draw(map)
end

function PassTurn()
  LogDebug("Turn is passed.")
  
  current_char = map:GetCurrentChar()
  if not current_char.is_player_controlled then
    LogDebug("Control is given to AI")
    UI.DisableControl()
    ai:StartMakingTurnForChar(current_char, map)
    is_player_turn = false
    need_ai_move = true
  else
    LogDebug("Control is given to player")
    is_player_turn = true
    UI.EnableControl()
    UI.SelectChar(current_char)
  end
end

function EndTurnButtonPressed()
  LogDebug("End turn button is pressed.")
  map:PassTurn()
  PassTurn()
end

function EndAITurn()
  is_player_turn = true
  need_ai_hit = false
  need_ai_move = false
  map:PassTurn()
  PassTurn()
end

function love.mousepressed(x, y, button, istouch)
  if (button ~= 1) then
    return
  end 
  
  UI.MousePressed(x, y, map)
  
end

function CharFinishedAttack(char, skill, cell_x, cell_y)
  map:ExecuteCharSkill(char, skill, cell_x, cell_y)

  if not is_player_turn then
    need_ai_move = true
  else
    UI.EnableControl()
    UI.SelectChar(map:GetCurrentChar())
  end
end

function CharFinishedMove()
  if not is_player_turn then
    need_ai_hit = true
  else
    UI.EnableControl()
    UI.SelectChar(map:GetCurrentChar())
  end
end
