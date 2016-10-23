require "skills/active_skill_base"
require "map/map_point"

Skills.Active.Fireball = {}
Skills.Active.Fireball.__index =  Skills.Active.Fireball

Skills.Active.Fireball.ap_cost = 3
Skills.Active.Fireball.damage = 18
Skills.Active.Fireball.img_src = '/assets/skills/scroll.png'
Skills.Active.Fireball.distance = 4
Skills.Active.Fireball.diameter = 3
Skills.Active.Fireball.name = "fireball"

function Skills.Active.Fireball.new()
  skill = {}
  setmetatable(skill, Skills.Active.Fireball)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.Fireball,{__index = Skills.Active.ActiveSkillBase})

