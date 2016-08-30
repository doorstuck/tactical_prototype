require "../globals"

CharacterBase = {}
CharacterBase.__index = CharacterBase

-- Move speed is pixels per second.
-- This means that character moves 2 cells per second.
default_move_speed = (cell_size * 2)

function CharacterBase.new(cell_x, cell_y, img_file)
  local char_base = {}
  setmetatable(char_base, CharacterBase)
  char_base.img = love.graphics.newImage(img_file)
  char_base.cell_x = cell_x
  char_base.cell_y = cell_y
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  char_base.x = x1
  char_base.y = y1
  char_base.move_speed = default_move_speed
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
  if not self.path or #self.path == 0 then return end
  -- First, are we in the same cell?
  time_left = dt
  
  pixels_to_next_cell = get_distance_to_cell(self.x, self.y, self.path[1].x, self.path[1].y)
  time_to_reach_next_cell = pixels_to_next_cell / self.move_speed
  while time_left > time_to_reach_next_cell do
    next_cell = table.remove(self.path, 1)
    self.x, self.y, temp_x, temp_y = get_cell_coordinates(next_cell.x, next_cell.y) 
    if (#self.path == 0) then return end
    time_left = time_left - time_to_reach_next_cell
    pixels_to_next_cell = get_distance_to_cell(self.x, self.y, self.path[1].x, self.path[1].y)
    time_to_reach_next_cell = pixels_to_next_cell / self.move_speed
  end

  -- Now, since we cannot move past next cell, move as many pixels as we can.
  
  pixels_to_move = dt * default_move_speed
  x1, y1, x2, y2 = get_cell_coordinates(self.path[1].x, self.path[1].y)
  dx = x1 - self.x
  dy = y1 - self.y
  if (dx == 0) then
    self.y =  self.y + self:MoveTowardsCoordinate(pixels_to_move, dy)
  elseif (dy == 0) then
    self.x =  self.x + self:MoveTowardsCoordinate(pixels_to_move, dx)
  else
    ratio_x = math.abs(dx / dy + dx)
    ratio_y = math.abs(dy / dy + dx)
    self.x = self.x + self:MoveTowardsCoordinate((pixels_to_move * ratio_x), dx)
    self.y =  self.y + self:MoveTowardsCoordinate((pixels_to_move * ration_y), dy)
  end
  
end

function CharacterBase:MoveTowardsCoordinate(pixels_to_move, direction)
  return pixels_to_move * (direction > 0 and 1 or -1)
end
