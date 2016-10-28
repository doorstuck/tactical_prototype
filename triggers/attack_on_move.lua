require "triggers/trigger_base"

Triggers.Move.AttackOnMove = {}
Triggers.Move.AttackOnMove.__index = Triggers.Move.AttackOnMove
Triggers.Move.AttackOnMove.name = "attack_on_move"

setmetatable(Triggers.Move.AttackOnMove,{__index = Triggers.Move})

function Triggers.Move.AttackOnMove.new(map)
  trigger = {}
  setmetatable(trigger, Triggers.Move.AttackOnMove)
  trigger.order = Triggers.preorder
  trigger.map = map
  return trigger
end

function Triggers.Move.AttackOnMove:Activate(moving_char, cell)
  LogDebug("Should attack on move trigger")
  for i, char in pairs(self.map:GetChars()) do
    if char.is_player_controlled ~= moving_char.is_player_controlled and next(char:GetConditions("attack_on_move")) ~= nil then
      LogDebug("Found opposing char with attack on move condition.")
      if math.abs(char.cell_x - moving_char.cell_x) <= 1 and math.abs(char.cell_y - moving_char.cell_y) <= 1 then
        self:Attack(char, moving_char)
      end
    end
  end
end

function Triggers.Move.AttackOnMove:Attack(attacker, moving_char)
  self.map:ExecuteCharSkill(attacker, attacker.base_skill, moving_char.cell_x, moving_char.cell_y, true --[[ don't do other triggers --]])
end
