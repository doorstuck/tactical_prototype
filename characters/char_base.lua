require "../globals"

CharacterBase = {}
CharacterBase.__index = CharacterBase

-- Move speed is pixels per second.
-- This means that character moves 2 cells per second.
default_move_speed = (cell_size * 5)

default_speed = 8
default_hit_points = 6

function CharacterBase.new(cell_x, cell_y, img_file, name, update_callback, updater)
  local char_base = {}
  setmetatable(char_base, CharacterBase)
  char_base.img = love.graphics.newImage(img_file)
  char_base.cell_x = cell_x
  char_base.cell_y = cell_y
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  char_base.x = x1
  char_base.y = y1
  char_base.name = name
  char_base.move_speed = default_move_speed
  char_base.update_callback = update_callback
  char_base.updater = updater
  char_base.max_ap = default_speed
  char_base.ap = default_speed
  char_base.is_player_controlled = true
  char_base.max_hp = default_hit_points
  char_base.hp = default_hit_points
  char_base.skills = {}
  char_base.passive_skills = {}
  char_base.base_attack = {}
  char_base.conditions = {}
  return char_base
end

function CharacterBase:Draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.img, math.ceil(self.x), math.ceil(self.y))
end

function CharacterBase:SetPath(path)
  self.path = path
  -- -1 because it also contains start point, which we don't want to count.
  self.ap = self.ap - (path:GetLength() - 1)
end 

function CharacterBase:DrawHP(hp_targeted)
  if not hp_targeted then hp_targeted = 0 end
  local hp_left_to_show = self.hp
  local x = self.x + hp_rect_padding
  local y = self.y + hp_rect_padding
  while (hp_left_to_show > 0) do
    if hp_left_to_show <= hp_targeted then
      love.graphics.setColor(230, 100, 0, 250)
    else
      love.graphics.setColor(0, 255, 0, 250)
    end
    love.graphics.rectangle("fill", x + 1, y + 1, hp_rect_width - 1, hp_rect_width - 1)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("line", x, y, hp_rect_width, hp_rect_width)
    x = x + hp_rect_padding + hp_rect_width
    if (x - self.x + hp_rect_width > cell_size - (2 * hp_rect_padding)) then
      -- Need to advance to the next row.
      y = y + hp_rect_width + hp_rect_padding
      x = self.x + hp_rect_padding
    end

    hp_left_to_show = hp_left_to_show - 1
  end
end

function CharacterBase:DrawAP(ap_spent)
  if not ap_spent then ap_spent = 0 end
  local x = ap_left_padding
  local y = screen_height - ap_bottom_padding - ap_size
  
  for i = 1, self.max_ap do
    if i > self.ap then
      -- action points already spent.
      love.graphics.setColor(230, 230, 230, 230)
    elseif i > self.ap - ap_spent then
      -- action points about to be spent.
      love.graphics.setColor(200, 180, 0, 150)
    else
      -- action points left.
      love.graphics.setColor(200, 200, 0, 255)
    end
    
    love.graphics.rectangle("fill", x, y, ap_size, ap_size)
    
    x = x + ap_side_padding + ap_size
  end
end

function CharacterBase:Move(dt)
  if not self.path or self.path:IsEmpty() then return end
  -- First, are we in the same cell?
  time_left = dt
  
  local next_cell = self.path:PeekFirst()
  
  pixels_to_next_cell = get_distance_to_cell(self.x, self.y, next_cell.cell_x, next_cell.cell_y)
  time_to_reach_next_cell = pixels_to_next_cell / self.move_speed

  while time_left > time_to_reach_next_cell do
    next_cell = self.path:RemoveFirst()
    self.x, self.y, temp_x, temp_y = get_cell_coordinates(next_cell.cell_x, next_cell.cell_y) 
    if (self.path:IsEmpty()) then 
      if (self.update_callback) then self.update_callback(self.updater, self.cell_x, self.cell_y, next_cell.cell_x, next_cell.cell_y) end
      self.cell_x = next_cell.cell_x
      self.cell_y = next_cell.cell_y
      return 
    end

    next_cell = self.path:PeekFirst()
    time_left = time_left - time_to_reach_next_cell
    pixels_to_next_cell = get_distance_to_cell(self.x, self.y, next_cell.cell_x, next_cell.cell_y)
    time_to_reach_next_cell = pixels_to_next_cell / self.move_speed
  end

  -- Now, since we cannot move past next cell, move as many pixels as we can.
  
  pixels_to_move = dt * default_move_speed
  x1, y1, x2, y2 = get_cell_coordinates(next_cell.cell_x, next_cell.cell_y)
  dx = x1 - self.x
  dy = y1 - self.y
  if (dx == 0) then
    self.y =  self.y + self:MoveTowardsCoordinate(pixels_to_move, dy)
  elseif (dy == 0) then
    self.x =  self.x + self:MoveTowardsCoordinate(pixels_to_move, dx)
  else
    local ratio_x = math.abs(dx / dy + dx)
    local ratio_y = math.abs(dy / dy + dx)
    self.x = self.x + self:MoveTowardsCoordinate((pixels_to_move * ratio_x), dx)
    self.y =  self.y + self:MoveTowardsCoordinate((pixels_to_move * ratio_y), dy)
  end
  
end

function CharacterBase:MoveTowardsCoordinate(pixels_to_move, direction)
  return pixels_to_move * (direction > 0 and 1 or -1)
end

function CharacterBase:CanUseSkill(skill)
  return self:CanUseSkillAfterMove(skill, 0 --[[ path length --]] )
end

function CharacterBase:CanUseSkillAfterMove(skill, path_length)
  if self.ap < skill:GetApCost(self) + path_length then return false end

  if not skill:CanUse(self) then return false end

  return true
end

function CharacterBase:ExecuteSkill(skill, map, cell_x, cell_y, modifiers)
  self.ap = self.ap - skill:GetApCost(self)
  skill:Execute(self, map, cell_x, cell_y, modifiers)
end

function CharacterBase:PassTurn()
  for i, skill in pairs(self.skills) do
    skill:PassTurn()
  end
  
  self.ap = self.max_ap
end

function CharacterBase:GetName()
  return self.name
end

function CharacterBase:GetConditions(name)
  local conditions = {}
  for i, condition in pairs(self.conditions) do
    if condition:GetName() == name then
      table.insert(conditions, condition)
    end
  end

  return conditions
end

function CharacterBase:GetAllConditions()
  return self.conditions
end

function CharacterBase:RemoveCondition(condition_to_remove)
  LogDebug("Removing condition " .. condition_to_remove:GetName() .. " from " .. self:GetName())
  for i, condition in pairs(self.conditions) do
    if condition_to_remove == condition then
      self.conditions[i] = nil
    end
  end
end

function CharacterBase:AddCondition(condition)
  LogDebug("Adding condition to " .. self:GetName() .. " condition: " .. condition:GetName())
  table.insert(self.conditions, condition)
end
