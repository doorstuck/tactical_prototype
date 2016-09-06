require "utils/log"
List = {}
List.__index = List

function List.new()
  local list = {}
  setmetatable(list, List)

  -- WTF you might think.
  -- Well, this is the way the list is inialized, so that we don't have to
  -- set these to nil and then init with proper values when last or first are
  -- inserted.
  -- Not very elegant, but it works.
  list.first = 0
  list.last = -1 

  list.elements = {}
  
  return list
end

function List:InsertLast(element)
  self.last = self.last + 1

  self.elements[self.last] = element
end

function List:InsertFirst(element)
  self.first = self.first - 1

  self.elements[self.first] = element
end

function List:PeekLast()
  if self:IsEmpty() then
    LogError("Tried to peek empty list with last")
    return nil
  end
  
  return self.elements[self.last]
end

function List:GetLength()
  return self.last - self.first + 1
end

function List:PeekFirst()
  if self:IsEmpty() then
    LogError("Tried to peek empty list with first")
    return nil
  end
  
  return self.elements[self.first]
end

function List:RemoveLast()
  if (self:IsEmpty()) then
    LogError("Tried to remove last from empty list.")
    return nil
  end 

  local element = self.elements[self.last]

  self.elements[self.last] = nil
  self.last = self.last - 1
  return element
end

function List:IsEmpty()
  return self.first > self.last
end

function List:RemoveFirst()
  if (self:IsEmpty()) then
    LogError("Tried to remove first from empty list.")
    return nil
  end
  
  local element = self.elements[self.first]

  self.elements[self.first] = nil
  self.first = self.first + 1
  return element
end
