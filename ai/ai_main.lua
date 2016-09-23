require "map/map_point"
require "utils/path_finder"

AI = {}
AI.__index = AI

move_cell_cost = -1
hit_hp_bonus = 5
hit_ally_cost = -10
-- bonus that multiplies the ratio of  attack_strength / total_health
percentage_hit_bonus = 10
-- bonus that grows large as left health grows smaller. (max_hp - hp + damage) / max_hp
closeness_to_death_bonus = 5
-- bonus for killing a character.
kill_bonus = 30

function AI.new()
  local ai = {}
  setmetatable(ai, AI)
  ai.current_char = nil
  ai.move_to_point = nil
  ai.target_skill = nil
  ai.target_point = nil
  ai.already_moved = false
  return ai 
end

function AI:MakeTurn(map)
  LogDebug("I, AI, move")
end

function AI:StartMakingTurnForChar(char, map)
  self.current_char = char
  self.move_to_point = nil
  self.target_skill = nil
  self.target_point = nil
  self.already_moved = false
end

function AI:WhereToMove(char, map)
  self:CalculateTurnForChar(char, map)
  if not self.move_to_point or (self.move_to_point.cell_x == char.cell_x and self.move_to_point.cell_y == char.cell_y) then
    return nil
  end
  
  return self.move_to_point
end

function AI:WhatToAttack(char, map)
  if self.target_skill and self.target_point then
    local target_skill = self.target_skill
    local target_point = self.target_point
    return target_skill, target_point
  end

  return nil
end

function AI:CalculateTurnForChar(char, map)
  local reachable_points = map:GetCharMovebalePoints(char)
  for i, skill in pairs(char.skills) do
  end
end

function AI.CalculateScore(target_point, skill, map, move_to_point, char)
  local path_lenght = move_to_point.path_length
  local score = path_length * move_cell_cost
  local chars_hit = {}
  for i, points in skill:CellsAffected(char, map, target_point.cell_x, target_point.cell_y) do
    local hit_char = map:GetChar(target_point.cell_x, target_point.cell_y)
    if hit_char then
      local hit_damage = skill:GetDamage(char)
      if hit_char.is_player_controlled then
        score = score + hit_hp_bonus * hit_damage
        score = score + percentage_hit_bonus * (hit_damage / hit_char.max_hp)
        score = score + closeness_to_death_bonus * ((hit_char.max_hp - hit_char.hp + hit_damage) / hit_char.max_hp)
        if hit_damage > hit_char.hp then score = score + kill_bonus
      else
        score = score + hit_damage * hit_ally_cost
      end
    end
  end

 return score
end

function AI.FindPointWithLessPath(points, reachable_points)
  local closest_point = { ["path_length"] = -1 }
  for hash, point in pairs(points) do
    if reachable_points[hash].path_length < closest_point.path_length or closest_point.path_length == -1 then
      closest_point = reachable_points[hash]
    end
  end

  return closest_point
end

function AI:GetPointsToMoveForAttack(char, map, skill, target_point, reachable_points)
  -- For a given point to attack find points that char needs to move to
  -- in order to make an attack to that point.
  
  local result = {}
  local max_points_to_return = 10

  local distance = skill:GetDistance()

  if distance() == 0 then
    if AI.IsPointInSet(reachable_points, target_point.cell_x - 1, target_point.cell_y) then
      AI.AddPointToSet(result, target_point.cell_x - 1, target_point.cell_y)
    end
    if AI.IsPointInSet(reachable_points, target_point.cell_x + 1, target_point.cell_y) then
      AI.AddPointToSet(result, target_point.cell_x + 1, target_point.cell_y)
    end
    if AI.IsPointInSet(reachable_points, target_point.cell_x, target_point.cell_y - 1) then
      AI.AddPointToSet(result, target_point.cell_x, target_point.cell_y - 1)
    end
    if AI.IsPointInSet(reachable_points, target_point.cell_x, target_point.cell_y + 1)  then
      AI.AddPointToSet(result, target_point.cell_x, target_point.cell_y + 1)
    end

    return result
  end

  -- What follows is a bit of a hack for now.
  -- We cannot compute all the points - it'd be too expensive, considering numbre of potential points.
  -- Instead, we want to quickly find a small amount of closest ones since they are most likely
  -- to be the ones with the shortest path to reach.

  -- Option number 1 - char is already in a place from where he can hit the enemy.
  if char.cell_x - target_point.cell_x <= distance and char.cell_y - target_point.cell_x <= distance then
    AI.AddPointToSet(result, char.cell_x, char.cell_y)
    return result
  end

  -- Option number 2 - char is within x, but no within y.
  if char.cell_x - target_point.cell_x <= distance then
    if char.cell_y < target_point.cell_y then
      return AI.AddPointsIfReachable(char.cell_x, target_y - distance, max_points, true, true, true, false, reachable_points, map)
    else
      return AI.AddPointsIfReachable(char.cell_x, target_y + distance, max_points, true, true, false, true, reachable_points, map)
    end
  end

  -- Option number 3 - char is within y, but not within x.
  if char.cell_y - target_point.cell_y <= distance then
    if char.cell_x < target_point.cell_x then
      return AI.AddPointsIfReachable(target_point.cell_x - distance, char.cell_y, max_points, false, true, true, true, reachable_points, map)
    else
      return AI.AddPointsIfReachable(target_point.cell_x + distance, char.cell_y, max_points, true, false, true, true, reachable_points, map)
    end
  end

  -- Option number 4 - we are totally out. Need to find nearest angle point.
  if target_point.cell_x - char.cell_x > distance then
    -- This is left corner.
    if target_point.cell_y - char.cell_y > distance then
    -- This is upper corner.
      return AI.AddPointsIfReachable(target_point.cell_x - distance, target_point.cell_y - distance, max_points, true, false, true, false, reachable_points, map)
    else
    -- This is lower corner.
      return AI.AddPointsIfReachable(target_point.cell_x - distance, target_point.cell_y + distance, max_points, true, false, false, true, reachable_points, map)
    end
  else
    -- This is right corner.
    if target_point.cell_y - char.cell_y > distance then
    -- This is upper corner.
      return AI.AddPointsIfReachable(target_point.cell_x + distance, target_point.cell_y - distance, max_points, false, true, true, false, reachable_points, map)
    else
    -- This is lower corner.
      return AI.AddPointsIfReachable(target_point.cell_x + distance, target_point.cell_y + distance, max_points, false, true, false, true, reachable_points, map)
    end
  end
end

function AI.AddPointsIfReachable(start_cell_x, start_cell_y, max_points, move_left, move_right, move_down, move_up, reachable_points, map)
  local queue = List.new()
  local result = {}
  local visited = {}
  local points_added = 0

  queue.AddLast(MapPoint.new(start_cell_x, start_cell_y))
  while not queue.IsEmpty() and points_added < max_points do
    curr_point = queue.RemoveFirst()
    if AI.IsPointInSet(reachable_points, curr_point.cell_x, curr_point.cell_y) then 
      AI.AddPointToSet(result, curr_point.cell_x, curr_point.cell_y) 
      points_added = points_added + 1
    end

    if move_left then
      AI.AddPointToQueueIfNotVisited(visited, queue, map, curr_point.cell_x - 1, curr_point.cell_y)
    end
    if move_right then
      AI.AddPointToQueueIfNotVisited(visited, queue, map, curr_point.cell_x + 1, curr_point.cell_y)
    end
    if move_down then
      AI.AddPointToQueueIfNotVisited(visited, queue, map, curr_point.cell_x, curr_point.cell_y + 1)
    end
    if move_up then
      AI.AddPointToQueueIfNotVisited(visited, queue, map, curr_point.cell_x, curr_point.cell_y - 1)
    end
  end
  
  return result
end

function AI.AddPointToQueueIfNotVisited(visited, queue, map, cell_x, cell_y)
  -- Name is misleading.
  -- Actually it not only adds to queue but also  to visited.
  -- Plus, it checks if point is acutally present on map.
  -- Oh, well...

  if not AI.IsPointsInSet(visited, cell_x, cell_y) and map.cells[MapPoint.CalculateHash(cell_x, cell_y)] then
    AI.AddPointToSet(visited, cell_x, cell_y)
    queue.AddLast(MapPoint.new(cell_x, cell_y))
  end
end

function AI.IsPointInSet(set, point_x, point_y)
  return set[MapPoint.CalculateHash(point_x, point_y)]
end

function AI.AddPointToSet(set, point_x, point_y)
  set[MapPoint.CalculateHash(point_x, point_y)] = MapPoint.new(point_x, point_y)
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
    if skill:GetDiameter() == 0 then
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

  return result;
end
