Point = {}
Point.__index = Point

function Point.new(x, y)
  local point = {}
  setmetatable(point, Point)
  point.x = x
  point.y = y
  return point
end
