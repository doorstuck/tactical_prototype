require "triggers/trigger_base"

Triggers.Move.AttackOnMove = {}
Triggers.Move.AttackOnMove.__index = Triggers.Move.AttackOnMove
Triggers.Move.AttackOnMove.name = "AttackOnMove"

setmetatable(Triggers.Move.AttackOnMove,{__index = Triggers.Move})

function Triggers.Move.AttackOnMove.new(attacker, map)
  trigger = {}
  setmetatable(trigger, Triggers.Move.AttackOnMove)
  trigger.attacker = attacker
  trigger.order = Triggers.preorder
  trigger.map = map
  return trigger
end


function Triggers.Move.AttackOnMove:ShouldTrigger(char, cell)
  if self.attacker.is_player_controlled == char.is_player_controlled then return false end
  return math.abs(self.attacker.cell_x - char.cell_x) <= 1 and math.abs(self.attacker.cell_y - char.cell_y) <= 1
end

function Triggers.Move.AttackOnMove:Activate(char, cell)
  self.map:ExecuteCharSkill(self.attacker, self.attacker.base_skill, char.cell_x, char.cell_y, true --[[ don't do other triggers --]])
end
