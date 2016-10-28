require "skills/passive_skill_base"
require "map/map_point"
require "triggers/attack_on_move"
require "conditions/condition_base"

Skills.Passive.AttackOnMove = {}
Skills.Passive.AttackOnMove.__index =  Skills.Passive.AttackOnMove

Skills.Passive.AttackOnMove.name = "attack_on_move"

function Skills.Passive.AttackOnMove.new(char)
  skill = {}
  setmetatable(skill, Skills.Passive.AttackOnMove)
  Skills.Passive.PassiveSkillBase.new(skill, char)
  return skill
end

setmetatable(Skills.Passive.AttackOnMove,{__index = Skills.Passive.PassiveSkillBase})

function Skills.Passive.AttackOnMove:Register(map, char)
  local attack_on_move_trigger = Triggers.Move.AttackOnMove.new(map)
  map:RegisterMoveTrigger(attack_on_move_trigger, map)
  self.char:AddCondition(Conditions.ConditionBase.new(self.char, self.char, self:GetName(), Conditions.Duration.Forever, 0, false))
end
