require "triggers/trigger_base"

Triggers.Attack.AttackMarked = {}
Triggers.Attack.AttackMarked.__index = Triggers.Attack.AttackMarked
Triggers.Attack.AttackMarked.name = "marked"

setmetatable(Triggers.Attack.AttackMarked,{__index = Triggers.Attack})

-- Each character that uses "Mark" skill should register this trigger.
-- It would automatically on register go through and unregister all
-- the mark triggers caused by this character.

function Triggers.Attack.AttackMarked.new(map)
  -- Char is the character that has marked an enemy.
  trigger = {}
  setmetatable(trigger, Triggers.Attack.AttackMarked)
  trigger.order = Triggers.preorder
  trigger.map = map
  return trigger
end

function Triggers.Attack.AttackMarked:Activate(attacker, target_cell, skill, modifiers)
  local attacked_char = self.map:GetChar(target_cell.cell_x, target_cell.cell_y)
  local marked_conditions = attacked_char:GetConditions("marked")

  for i, marked_condition in pairs(marked_conditions) do
    LogDebug("Got marked condition!")
    LogDebug("Starter " .. marked_condition.char_starter:GetName())
    LogDebug("Attacker" .. attacker:GetName())
    if marked_condition.char_starter == attacker then
      LogDebug("It's him!")
      local modifier = {}
      modifier.is_percent = true
      -- +100%, i.e. double damage.
      modifier.value = 1
      table.insert(modifiers, modifier)
    end
  end
end
