require "skills/skill_base"

Skills.Active.ActiveSkillBase = {}

Skills.Active.ActiveSkillBase.__index = Skills.Active.ActiveSkillBase

Skills.Active.ActiveSkillBase.cooldown = 0
Skills.Active.ActiveSkillBase.ap_cost = 0
Skills.Active.ActiveSkillBase.damage = 0
Skills.Active.ActiveSkillBase.img_src = ""
Skills.Active.ActiveSkillBase.diameter = 0
Skills.Active.ActiveSkillBase.distance = 0
Skills.Active.ActiveSkillBase.name = "skill base"

function Skills.Active.ActiveSkillBase.new(skill)
  skill.turns_till_cooldown = 0
  skill.img = love.graphics.newImage(skill.img_src)
end

function Skills.Active.ActiveSkillBase.CanTarget(char, map, target_cell_x, target_cell_y)
  return false
end

function Skills.Active.ActiveSkillBase:PassTurn()
  if self.turns_till_cooldown > 0 then
    self.turns_till_cooldown = self.turns_till_cooldown - 1
  end
end

function Skills.Active.ActiveSkillBase:CanUse(char)
  return self.turns_till_cooldown <= 0
end

function Skills.Active.ActiveSkillBase:GetApCost(char)
  return self.ap_cost
end

function Skills.Active.ActiveSkillBase:GetDamage(char, modifiers)
  return self.ComputeDamage(self.damage, modifiers)
end

function Skills.Active.ActiveSkillBase:Execute(char, map, target_cell_x, target_cell_y)
  self.turn_till_cooldown = self.cooldown
end

function Skills.Active.ActiveSkillBase.IsEnemy(char, map, target_cell_x, target_cell_y)
  target_char = map:GetChar(target_cell_x, target_cell_y)
  if not target_char then return false end
  return char.is_player_controlled and not target_char.is_player_controlled
end

function Skills.Active.ActiveSkillBase:CanTarget(char, map, target_cell_x, target_cell_y)
  local is_enemy = Skills.Active.ActiveSkillBase.IsEnemy(char, map, target_cell_x, target_cell_y) 

  -- If radius is not 0, it's only possible to target an enemy.
  if not is_enemy and self.radius == 0 then return false end

  if self.distance == 0 then
    -- Special case. Distance = 0 means that only next cells can be attacked.
    return math.abs(target_cell_x - char.cell_x) <= 1 and math.abs(target_cell_y - char.cell_y) <= 1
  end

  return math.abs(char.cell_x - target_cell_x) < self.distance and math.abs(char.cell_y - target_cell_y) < self.distance
end

function Skills.Active.ActiveSkillBase:Draw(x, y, disabled)
  if disabled then
    love.graphics.setColor(255, 255, 255, 100)
  else
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.draw(self.img, x, y)
end

function Skills.Active.ActiveSkillBase:GetDiameter()
  -- Returns the diameter of the attack.
  -- 0 means targetting character only.
  return self.diameter
end

function Skills.Active.ActiveSkillBase:GetDistance()
  -- Distance at which the attack can be made from attacker.
  -- 0 means close combat only.
  return self.distance
end

function Skills.Active.ActiveSkillBase:GetName()
  return self.name
end

function Skills.Active.ActiveSkillBase:CellsAffected(char, map, target_cell_x, target_cell_y)
  -- Input arguments: map, character that uses that skill (in case she has any passive skills
  -- that can change the effect of that skill), and target cell.
  -- Returns Array of cells that are affected by this skill.
  result = {}
  if self.diameter == 0 then
    point = MapPoint.new(target_cell_x, target_cell_y)
    table.insert(result, point)
    return result
  end

  -- Honetsly, I don't know how to comment it, it needs to be drawn on paper to be understood.
  -- I just hope that it ever works and I won't need to change this code or look at it ever again.

  local mod = (self.diameter - 1) % 2
  local start = math.floor((self.diameter - 1) / 2)
  local finish = math.floor((self.diameter - 1) / 2) + mod

  for cell_x = target_cell_x - start, target_cell_x + finish, 1 do
    for cell_y = target_cell_y - start, target_cell_y + finish, 1 do
      point = MapPoint.new(cell_x, cell_y)
      table.insert(result, point)
    end
  end

  return result
end

function Skills.Active.ActiveSkillBase:Execute(char, map, target_cell_x, target_cell_y, modifiers)
  for i, cell_affected in pairs(self:CellsAffected(char, map, target_cell_x, target_cell_y)) do
    target_char = map:GetChar(cell_affected.cell_x, cell_affected.cell_y)
    if target_char then
      target_char.hp = target_char.hp - self:GetDamage(char, modifiers)
    end
  end
end

function Skills.Active.ActiveSkillBase.ComputeDamage(initial_damage, modifiers)
  LogDebug("Computing damage")
  if not modifiers then return initial_damage end
  LogDebug(modifiers)

  local total_damage = initial_damage

  -- first: go with non-percent modifiers.
  for i, modifier in pairs(modifiers) do
    if not modifier.is_percent then
      total_damage = total_damage + modifier.value
    end
  end

  -- second: go with percent modifiers.

  for i, modifier in pairs(modifiers) do
    if modifier.is_percent then
      total_damage = total_damage * (1 + modifier.value)
    end
  end

  return total_damage
end
