require "map/map_point"
require "utils/path_finder"

AI = {}
AI.__index = AI


function AI.new()
  local ai = {}
  setmetatable(ai, AI)
  return ai 
end

function AI:MakeTurn(map)
  LogDebug("I, AI, move")
end
