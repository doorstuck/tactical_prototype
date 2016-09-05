require "utils/log"
List = {}
List.__index = List

function List.new()
  local list = {}
  setmetatable(list, List)

  list.first = 0
  list.last = 0

  list.elements = {}
  
  return list
end

function List:InsertLast(element)
  self.last = self.last + 1
  if (self.first == 0) then
    self.first = 1
  end

  self.elements[self.last] = element
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
  return self.first == 0 or self.first > self.last
end

function List:RemoveFirst()
  if (self:IsEmpty()) then
    LogError("Tried to remove first from empty list.")
    return nil
  end
  
  local element = self.elements[self.first]

  self.elements[self.first] = nil
  self.first = self.first + 1
  LogDebug("First now is " .. self.first)
  LogDebug("Last now is " .. self.last)
  return element
end
