Triggers = {}
Triggers.__index = Triggers

Triggers.preorder = 0
Triggers.inorder = 1
Triggers.postorder = 2

Triggers.name = ""


Triggers.Move = {}
setmetatable(Triggers.Move,{__index = Triggers})

Triggers.Move.__index = Triggers.Move

function Triggers:GetName()
  return self.name
end

function Triggers.Move:ShouldTrigger(char, cell)
  -- This function is invoked every time a character moves to
  -- check if trigger should actually take effect.
  -- char is character that moved.
  -- cell is characters destination.

  return false
end

function Triggers:Activate(char, cell)
  -- Activate is called to actually resolve effect of the trigger.
  -- Parameters are same as for ShouldTrigger.
end

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

Triggers.Attack = {}
setmetatable(Triggers.Attack,{__index = Triggers})

Triggers.Attack.Retaliate = {}
Triggers.Attack.Retaliate.__index = Triggers.Attack.Retaliate
Triggers.Attack.Retaliate.name = "Retaliate"

setmetatable(Triggers.Attack.Retaliate,{__index = Triggers.Attack})

function Triggers.Attack.Retaliate.new(char, map)
  trigger = {}
  setmetatable(trigger, Triggers.Attack.Retaliate)
  trigger.char = char 
  trigger.order = Triggers.postorder
  trigger.map = map
  return trigger
end

function Triggers.Attack.Retaliate:ShouldTrigger(attacker, target_cell, skill)
  return skill.distance == 0 and skill.diameter == 0 and target_cell.cell_x == self.char.cell_x and target_cell.cell_y == self.char.cell_y
end

function Triggers.Attack.Retaliate:Activate(attacker, target_cell, skill)
  -- We don't want to do other triggers because it might cause a reaction, for example when char with retaliation attacks another one
  -- with retaliation.
  self.map:ExecuteCharSkill(self.char, self.char.base_skill, attacker.cell_x, attacker.cell_y, true --[[ don't do other triggers --]])
end
