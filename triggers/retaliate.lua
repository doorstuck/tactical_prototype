require "triggers/trigger_base"

Triggers.Attack.Retaliate = {}
Triggers.Attack.Retaliate.__index = Triggers.Attack.Retaliate
Triggers.Attack.Retaliate.name = "retaliate"

setmetatable(Triggers.Attack.Retaliate,{__index = Triggers.Attack})

function Triggers.Attack.Retaliate.new(map)
  trigger = {}
  setmetatable(trigger, Triggers.Attack.Retaliate)
  trigger.order = Triggers.postorder
  trigger.map = map
  return trigger
end

function Triggers.Attack.Retaliate:ShouldTrigger(attacker, target_cell, skill)
  return skill.distance == 0 and skill.diameter == 0 and target_cell.cell_x == self.char.cell_x and target_cell.cell_y == self.char.cell_y
end

function Triggers.Attack.Retaliate:Activate(attacker, target_cell, skill, modifiers)
  local attacked_char = map:GetChar(target_cell.cell_x, target_cell.cell_y)

  if not attacker_char then
    return
  end

  if next(attacked_char:GetConditions("retaliate")) ~= nil and skill.distance == 0 and skill.diameter == 0 then
    -- We don't want to do other triggers because it might cause a reaction, for example when char with retaliation attacks another one
    -- with retaliation.
    self.map:ExecuteCharSkill(attacked_char, attacked_char.base_skill, attacker.cell_x, attacker.cell_y, true --[[ don't do other triggers --]])
  end
end
