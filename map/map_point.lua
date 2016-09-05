MapPoint = {}
MapPoint.__index = MapPoint

function MapPoint.new(cell_x, cell_y)
  local point = {}
  setmetatable(point, MapPoint)
  point.cell_x = cell_x
  point.cell_y = cell_y
  point.passable = true
  return point
end

function MapPoint:GetHash()
  -- Don't expect more than 9999 horizontal cells
  -- Hack: negative points all hash to 0.
  if (self.cell_x < 0 or self.cell_y < 0) then return -1 end
  return self.cell_x * 10000 + self.cell_y
end

function MapPoint:Equals(other)
  return self.cell_x == other.cell_x and self.cell_y == other.cell_y
end

function MapPoint.CalculateHash(cell_x, cell_y)
  local point = MapPoint.new(cell_x, cell_y)
  return point:GetHash()
end

function MapPoint:ToString()
  return "x " .. self.cell_x .. " y " .. self.cell_y
end
