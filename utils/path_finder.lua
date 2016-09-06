require "utils/list"

PathFinder = {}
PathFinder.__index = PathFinder

function PathFinder.FindAllReachablePoints(map, origin_point, length_limit)
  -- Args:
  --   map_points: table of map point hashes to the prev_point and length.
  -- returns a table of a type:
  -- hash to the list of points in the path
  local result_table = {}

  local list = List.new()
  list:InsertLast({["point"] = origin_point, ["path_length"] = 0, ["prev_point"] = nil})
  
  PathFinder.FindAllReachablePointsInternal(map, list, length_limit, result_table)

  return result_table
end

function PathFinder.FindAllReachablePointsInternal(map, list, length_limit, result_table)
  if (not length_limit) or length_limit <= 0 then return end
  while (not list:IsEmpty()) do
    removed_item = list:RemoveFirst()

    current_point = removed_item["point"]
    path_length = removed_item["path_length"]
    prev_point = removed_item["prev_point"]

    if (not current_point) then goto continue end
    if (length_limit < path_length) then goto continue end

    -- Already visited and visited quicker than this.
    if (result_table[current_point:GetHash()] and result_table[current_point:GetHash()].path_length < path_length) then goto continue end

    do
      local up_point = map.cells[MapPoint.CalculateHash(current_point.cell_x, current_point.cell_y - 1)]
      local down_point = map.cells[MapPoint.CalculateHash(current_point.cell_x, current_point.cell_y + 1)]
      local left_point = map.cells[MapPoint.CalculateHash(current_point.cell_x - 1, current_point.cell_y)]
      local right_point = map.cells[MapPoint.CalculateHash(current_point.cell_x + 1, current_point.cell_y)]
      
      PathFinder.InsertNextPoint(current_point, up_point, map, path_length + 1, list)
      PathFinder.InsertNextPoint(current_point, down_point, map, path_length + 1, list)
      PathFinder.InsertNextPoint(current_point, left_point, map, path_length + 1, list)
      PathFinder.InsertNextPoint(current_point, right_point, map, path_length + 1, list)

      PathFinder.GetToNextPoint(map, current_point, prev_point, path_length, length_limit, result_table)
    end

    ::continue::
  end
end

function PathFinder.InsertNextPoint(prev_point, next_point, map, path_length, list)
  if (not next_point) then return end
  if (not map:IsPassable(next_point.cell_x, next_point.cell_y)) then return end
  list:InsertLast({ ["point"] = next_point, ["path_length"] = path_length, ["prev_point"] = prev_point })
end

function PathFinder.GetToNextPoint(map, current_point, prev_point, path_length, length_limit, result_table)
  -- Already visited and visited quicker than this.
  result_table[current_point:GetHash()] = {}
  result_table[current_point:GetHash()].path_length = path_length
  result_table[current_point:GetHash()].prev_point = prev_point
  result_table[current_point:GetHash()].point = current_point
end
