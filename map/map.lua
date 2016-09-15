require "map/map_point"
require "utils/path_finder"

Map = {}
Map.__index = Map

function Map.new(cells, chars, char_moved_callback, pass_turn_callback)
  local map = {}
  setmetatable(map, Map)

  map.cells = {}
  map.chars = {}
  map.paths = {}
  map.char_moved_callback = char_moved_callback
  map.pass_turn_callback = pass_turn_callback
  map:AddCells(cells)
  map:AddChars(chars)
  
  return map
end

function Map:PassTurn()
  for i, char in pairs(self.chars) do
    char:PassTurn()
  end
end

function Map:IsPassable(cell_x, cell_y)
  local map_point = MapPoint.new(cell_x, cell_y)
  local point_hash = map_point:GetHash()
  if (self.cells[point_hash].passable and not self.chars[point_hash]) then
    return true
  end 

  return false
end

function Map:GetChar(cell_x, cell_y)
  local map_point = MapPoint.new(cell_x, cell_y)
  local point_hash = map_point:GetHash()

  return self.chars[point_hash]
end

function Map:AddCells(cells)
  for i, cell in ipairs(cells) do
    self.cells[cell:GetHash()] = cell
  end
end

function Map:AddChars(chars)
  for i, char in ipairs(chars) do
    char.update_callback = self.UpdateCharPosition
    char.updater = self
    char_cell = MapPoint.new(char.cell_x, char.cell_y)
    self.chars[char_cell:GetHash()] = char
  end
end

function Map:DrawChars()
  for i, char in pairs(self.chars) do
    char:Draw()
  end
end

function Map:MoveChars(dt)
  for i, char in pairs(self.chars) do
    char:Move(dt)
  end
end

function Map.GenerateCells(horizontal_cells, vertical_cells)
  local cells = {}
  for i = 0, horizontal_cells - 1 do
    for j = 0, vertical_cells - 1 do
      table.insert(cells, MapPoint.new(i, j))
    end
  end

  return cells
end

function Map.UpdateCharPosition(map, prev_cell_x, prev_cell_y, new_cell_x, new_cell_y)
  local prev_hash = MapPoint.CalculateHash(prev_cell_x, prev_cell_y)
  local new_hash = MapPoint.CalculateHash(new_cell_x, new_cell_y)

  map.chars[new_hash] = map.chars[prev_hash]
  map.chars[prev_hash] = nil
  
  -- update cached character path because she moved.
  map.paths = {}
  if map.char_moved_callback then map.char_moved_callback() end
  map:EndPlayerTurnIfNeeded()
end

function Map:GetCharMoveblePoints(cell_x, cell_y)
  char_point_hash = MapPoint.CalculateHash(cell_x, cell_y)
  char = self.chars[char_point_hash]
  if (not char) then return nil end

  points = self.paths[char_point_hash]
  if (points) then return points end

  points = PathFinder.FindAllReachablePoints(self, MapPoint.new(cell_x, cell_y), char.ap)

  self.paths[char_point_hash] = points

  return points
end

function Map:ExecuteCharSkill(char, skill, cell_x, cell_y)
  char:ExecuteSkill(skill, self, cell_x, cell_y)
  self.paths[MapPoint.CalculateHash(char.cell_x, char.cell_y)] = nil
  self:RemoveDeadChars()
  self:EndPlayerTurnIfNeeded()
end

function Map:RemoveDeadChars()
  for i, char in pairs(self.chars) do
    if char.hp <= 0 then
      self.chars[i] = nil
    end
  end
end

function Map:MoveChar(char, cell_x, cell_y)
  path = self:GetPathForChar(char, cell_x, cell_y)
  if not path then
    LogError("Tried to move char to a position that she cannot move to.")
    LogError("Char x: " .. char.cell_x .. " y: " .. char.cell_y)
    LogError("Destination: x: " .. cell_x .. " y: " .. cell_y)
    return
  end
  
  char:SetPath(path)
end

function Map:GetPathForChar(char, cell_x, cell_y)
  local points = self.paths[MapPoint.CalculateHash(char.cell_x, char.cell_y)] 
  if not points then
    return nil
  end

  return Map.PointToMoveVector(points, cell_x, cell_y)
end

function Map.PointToMoveVector(points, dest_cell_x, dest_cell_y)
  -- Returns a list of points in the order of how to move char. 
  list = List.new()
  prev_point = MapPoint.new(dest_cell_x, dest_cell_y)
  while (prev_point) do
    list:InsertFirst(prev_point)
    curr_point = points[MapPoint.CalculateHash(prev_point.cell_x, prev_point.cell_y)]
    if not curr_point then
      -- impossible to reach original point from this destination.
      return nil
    end
    prev_point = curr_point.prev_point
  end

  if list:IsEmpty() then return nil end
  return list
end

function Map:EndPlayerTurnIfNeeded()
  local player_chars_active = false
  for i, char in pairs(self.chars) do
    if char.is_player_controlled and char.ap > 0 then
      player_chars_active = true
    end
  end
  
  if not player_chars_active then
    self:pass_turn_callback()
  end
end
