require "conditions/condition_base"

Conditions.Marked = {}
Conditions.Marked.__index =  Conditions.Marked

Conditions.Marked.name = "marked"
Conditions.Marked.duration = Conditions.Duration.Forever

function Conditions.Marked.new()
  condition = {}
  setmetatable(condition, Conditions.Marked)
  Conditions.ConditionBase.new(skill)
  return skill
end

setmetatable(Conditions.Marked,{__index = Conditions.ConditionBase})
