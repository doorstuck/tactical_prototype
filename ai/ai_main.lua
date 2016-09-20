require "map/map_point"
require "utils/path_finder"

AI = {}
AI.__index = AI


function AI.new()
  local ai = {}
  setmetatable(ai, AI)
  return ai 
end

function AI:MakeTurn(map)
  LogDebug("I, AI, move")
end

function AI:MakeTurnForChar(char, map)
  reachable_points = map:GetCharMovebalePoints(char)
  for i, skill in pairs(char.skills) do
  end
end

function AI:GetPointsThatCanBeTargeted(char, map, skill)
  result = {}
  -- We will try only to hit cells where strike would
  -- affect an enemy.
  enemies = {}
  diameter = skill:GetDiameter()

  for i, target_char in pairs(map.chars) do
    if target_char.is_player_controlled then
      table.insert(enemies, target_char)
    end
  end

  for i, enemy in pairs(enemies) do
    enemy_point = MapPoint.new(enemy.cell_x, enemy.cell_y)
    if skill:GetDiameter() = 0 then
      result[enemy_point:GetHash()] = enemy_point
    else
      -- Same as code in ActiveSkillBase just reversed oreder of event diameter.
      -- See comment there (though it does not explain how it works).
      local mod = (self.diameter - 1) % 2
      local start = math.floor((self.diameter - 1) / 2) + mod
      local finish = math.floor((self.diameter - 1) / 2)

      for cell_x = target_cell_x - start, target_cell_x + finish, 1 do
        for cell_y = target_cell_y - start, target_cell_y + finish, 1 do
          point = MapPoint.new(cell_x, cell_y)
          result[point:GetHash()] = point
        end
      end
    end
  end
end
