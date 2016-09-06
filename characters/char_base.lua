require "../globals"

CharacterBase = {}
CharacterBase.__index = CharacterBase

-- Move speed is pixels per second.
-- This means that character moves 2 cells per second.
default_move_speed = (cell_size * 5)

default_speed = 5

function CharacterBase.new(cell_x, cell_y, img_file, update_callback, updater)
  local char_base = {}
  setmetatable(char_base, CharacterBase)
  char_base.img = love.graphics.newImage(img_file)
  char_base.cell_x = cell_x
  char_base.cell_y = cell_y
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  char_base.x = x1
  char_base.y = y1
  char_base.move_speed = default_move_speed
  char_base.update_callback = update_callback
  char_base.updater = updater
  char_base.speed = default_speed
  char_base.action_points = default_speed
  return char_base
end

function CharacterBase:Draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.img, math.ceil(self.x), math.ceil(self.y))
end

function CharacterBase:SetPath(path)
  self.path = path
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
