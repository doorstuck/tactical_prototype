require "map/map_point"
require "utils/path_finder"

Map = {}
Map.__index = Map

function Map.new(cells, chars)
  local map = {}
  setmetatable(map, Map)

  map.cells = {}
  map.chars = {}
  map.paths = {}
  map:AddCells(cells)
  map:AddChars(chars)
  
  return map
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
  for i = 0, horizontal_cells do
    for j = 0, vertical_cells do
      table.insert(cells, MapPoint.new(i, j))
    end
  end

  return cells
end

function Map.UpdateCharPosition(map, prev_cell_x, prev_cell_y, new_cell_x, new_cell_y)
  local prev_hash = MapPoint.CalculateHash(prev_cell_x, prev_cell_y)
  local new_hash = MapPoint.CalculateHash(next_cell_x, next_cell_y)

  map.chars[new_hash] = map.chars[prev_hash]
  map.chars[prev_hash] = nil
  
  -- update cached character path because she moved.
  map.paths[prev_hash] = nil
end

function Map:GetCharMoveblePoints(cell_x, cell_y)
  LogDebug("Getting moveble points")
  char_point_hash = MapPoint.CalculateHash(cell_x, cell_y)
  char = self.chars[char_point_hash]
  if (not char) then return nil end

  LogDebug("Char is found")

  points = self.paths[char_point_hash]
  if (points) then return points end

  LogDebug("Points are not found")

  points = PathFinder.FindAllReachablePoints(self, MapPoint.new(cell_x, cell_y), 5)

  LogDebug("And number of points is " .. #points)

  self.paths[char_point_hash] = points

  return points

end
