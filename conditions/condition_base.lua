Condidtions = {}

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

function Conditions.ConditionBase.new(condition, map, char)
  -- char is the char that has this condition.
  condition.current_turn = 0
  condition.map = map
  condition.char = char
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

function Conditions.ConditionBase:OnStart()
end

function Conditions.ConditionBase:OnEnd()
end
