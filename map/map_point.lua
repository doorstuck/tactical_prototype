MapPoint = {}
MapPoint.__index = MapPoint

function MapPoint.new(cell_x, cell_y)
  local file = io.open("e:\\game_prototyping\\logs.txt", "a")
  local point = {}
  setmetatable(point, MapPoint)
  point.cell_x = cell_x
  point.cell_y = cell_y
  point.passable = true
  return point
end

function MapPoint:GetHash()
  -- Don't expect more than 9999 horizontal cells
  return self.cell_x * 10000 + self.cell_y
end

function MapPoint:Equals(other)
  return self.cell_x == other.cell_x and self.cell_y == other.cell_y
end
