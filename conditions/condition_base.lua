Conditions = {}

Conditions.ConditionBase = {}

Conditions.ConditionBase.__index = Conditions.ConditionBase

-- Enum for duration of condition.
Conditions.Duration = {}
-- Condition ends emmidiately after character finishes his turn.
Conditions.Duration.CharTurn = 0
-- Condition ends after specified number of turns. Turns are full rounds
-- till char who originally casted this condition starts her turn again.
Conditions.Duration.FullTurn = 1
-- This is forever, or till it's cancelled.
Conditions.Duration.Forever = 2

-- Name is unique identifier that other conditions or triggers might find
-- it with.
Conditions.ConditionBase.name = "base_condition"

-- Char that started this condition. Needed to identify where to count
-- lifespan from.
Conditions.ConditionBase.char_starter = nil

-- How many turns would this condition live? Only needed if duration is set
-- to FullTurn.
Conditions.ConditionBase.turns_to_live = 0

-- Current turn for this condition. Needed to count number of turns till 
-- this condition should be removed.
Conditions.ConditionBase.current_turn = 0

Conditions.ConditionBase.duration = Conditions.Duration.Forever

-- Remove this condition if starter has died. Otherwise, starter would be passed to the next
-- character in chain.
Conditions.ConditionBase.remove_if_starter_dies = true

function Conditions.ConditionBase.new(char, char_starter, name, duration, turns_to_live, remove_if_started_dies)
  -- char is the char that has this condition.
  -- char_started is the char that has set this condition. This is needed to know when to
  -- remove this conditions if it outlived it's turns.
  -- Turns are counted whenever char_started gets turn again.
  condition = {}
  setmetatable(condition, Conditions.ConditionBase)

  condition.current_turn = 0
  condition.char = char
  condition.char_starter = char_starter
  condition.name = name
  condition.duration = duration
  condition.turns_to_live = turns_to_live
  condition.remove_if_starter_dies = remove_if_starter_dies
  return condition
end

function Conditions.ConditionBase:ShouldBeRemoved()
  return self.duration == Conditions.Duration.CharTurn or
         (self.duration == Conditions.Duration.FullTurn and
             self.current_turn >= self.turns_to_live)
end

function Conditions.ConditionBase:PassTurn(char)
  -- char is the next character who start her turn.

  if char == self.char_starter then
    self.current_turn = self.current_turn + 1
  end
end

function Conditions.ConditionBase:SetStarter(new_starter)
  LogDebug("Reassigning starter from " .. self.char_starter:GetName() .. " to " .. new_starter:GetName() .. " for " .. self:GetName())
  self.char_starter = new_starter
end

function Conditions.ConditionBase:GetName()
  return self.name
end
