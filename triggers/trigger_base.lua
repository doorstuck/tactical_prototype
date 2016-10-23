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

Triggers.Attack = {}
setmetatable(Triggers.Attack,{__index = Triggers})
