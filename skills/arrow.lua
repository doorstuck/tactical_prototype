require "skills/active_skill_base"
require "map/map_point"

Skills.Active.Arrow = {}
Skills.Active.Arrow.__index =  Skills.Active.Arrow

Skills.Active.Arrow.ap_cost = 3
Skills.Active.Arrow.damage = 18
Skills.Active.Arrow.img_src = '/assets/skills/scroll.png'
Skills.Active.Arrow.distance = 4
Skills.Active.Arrow.diameter = 0
Skills.Active.Arrow.name = "fireball"

function Skills.Active.Arrow.new()
  skill = {}
  setmetatable(skill, Skills.Active.Arrow)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.Arrow,{__index = Skills.Active.ActiveSkillBase})
