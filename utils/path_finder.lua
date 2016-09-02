

function PathFinder.FindAllReachablePoints(map, origin_point, length_limit)
  -- Args:
  --   map_points: table of map points hashes to the map points.
  -- returns a table of a type:
  -- hash to the list of points in the path
  local result_table = {}
  
  PathFinder.FindAllReachablePointsInternal(map, origin_point, lenght_limit, result_table)

  return result_table
end


function PathFinder.FindAllReachablePointsInternal(map, current_point, length_limit, result_table)
  if (not length_limit) or lenght_limit <= 0 then return end

  local up_point = map.cells[MapPoint.CalculateHash(current_point.cell_x, current_point.cell_y - 1)]
  local down_point = map.cells[MapPoint.CalculateHash(current_point.cell_x, current_point.cell_y + 1)]
  local left_point = map.cells[MapPoint.CalculateHash(current_point.cell_x - 1, current_point.cell_y)]
  local right_point = map.cells[MapPoint.CalculateHash(current_point.cell_x + 1, current_point.cell_y)]
  
  PathFinder.GetToNextPoint(map, current_point, up_point, lenght_limit, result_table)
  PathFinder.GetToNextPoint(map, current_point, down_point, lenght_limit, result_table)
  PathFinder.GetToNextPoint(map, current_point, left_point, lenght_limit, result_table)
  PathFinder.GetToNextPoint(map, current_point, right_point, lenght_limit, result_table)

end

function PathFinder.GetToNextPoint(map, current_point, next_point, length_limit, result_table)
  if (not next_point) then return end
  -- Already visited.
  if (result_table[next_point:GetHash()]) then return end
  if (not map:IsPassable(next_point.cell_x, next_point.cell_y)) then return end

  result_table[next_point:GetHash()] = current_point

  PathFinder.FindAllReachablePointsInternal(map, next_point, length_limit - 1, result_table)
end
