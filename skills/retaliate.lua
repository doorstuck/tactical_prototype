require "skills/passive_skill_base"
require "map/map_point"
require "triggers"

Skills.Passive.Retaliate = {}
Skills.Passive.Retaliate.__index =  Skills.Passive.Retaliate

Skills.Passive.Retaliate.name = "fireball"

function Skills.Passive.Retaliate.new(char)
  skill = {}
  setmetatable(skill, Skills.Passive.Retaliate)
  Skills.Passive.PassiveSkillBase.new(skill, char)
  return skill
end

setmetatable(Skills.Passive.Retaliate,{__index = Skills.Passive.PassiveSkillBase})

function Skills.Passive.Retaliate:Register(map, char)
  local retaliate_trigger = Triggers.Attack.Retaliate.new(self.char, map)
  map:RegisterAttackTrigger(retaliate_trigger, map)
end
