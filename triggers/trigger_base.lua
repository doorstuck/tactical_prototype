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

function Triggers:Activate(char, cell)
  -- Activate is called to actually resolve effect of the trigger.
  -- Check the condition for actually resolving trigger here.
end

Triggers.Attack = {}
setmetatable(Triggers.Attack,{__index = Triggers})
