require "skills/active_skill_base"
require "map/map_point"

Skills.Active.MeleeStrike = {}
Skills.Active.MeleeStrike.__index =  Skills.Active.MeleeStrike

Skills.Active.MeleeStrike.ap_cost = 3
Skills.Active.MeleeStrike.damage = 18
Skills.Active.MeleeStrike.img_src = '/assets/skills/sword.png'
Skills.Active.MeleeStrike.name = 'melee_strike'

function Skills.Active.MeleeStrike.new()
  skill = {}
  setmetatable(skill, Skills.Active.MeleeStrike)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.MeleeStrike,{__index = Skills.Active.ActiveSkillBase})
