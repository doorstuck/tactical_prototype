
require "skills/active_skill_base"
require "map/map_point"
require "triggers/attack_marked"

Skills.Active.Mark = {}
Skills.Active.Mark.__index =  Skills.Active.Mark

Skills.Active.Mark.ap_cost = 1
Skills.Active.Mark.damage = 0
Skills.Active.Mark.img_src = '/assets/skills/bow.png'
Skills.Active.Mark.distance = 40
Skills.Active.Mark.diameter = 0
Skills.Active.Mark.name = "mark"

function Skills.Active.Mark.new()
  skill = {}
  setmetatable(skill, Skills.Active.Mark)
  Skills.Active.ActiveSkillBase.new(skill)
  return skill
end

setmetatable(Skills.Active.Mark,{__index = Skills.Active.ActiveSkillBase})

function Skills.Active.Mark:Execute(char, map, target_cell_x, target_cell_y, modifiers)
  LogDebug("Executing mark")
  self:RemoveMarksByChar(char, map)
  
  local target = map:GetChar(target_cell_x, target_cell_y)
  local condition = Conditions.ConditionBase.new(target, char, "marked", Conditions.Duration.Forever, 0, true)

  target:AddCondition(condition)

  local mark_trigger = Triggers.Attack.AttackMarked.new(map)
  map:RegisterAttackTrigger(mark_trigger)
end

function Skills.Active.Mark:RemoveMarksByChar(attacker, map)
  for i, char in pairs(map:GetChars()) do
    for j, marked_condition in pairs(char:GetConditions("marked")) do
      if marked_condition.char_starter == attacker then
        char:RemoveCondition(marked_condition)
      end
    end
  end
end

function Skills.Active.Mark:GetDamage()
  return 0
end
