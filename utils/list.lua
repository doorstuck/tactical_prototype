require "log"
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

function List:Insert(element)
  self.last = self.last + 1
  if (self.first == 0) then
    self.first = 1
  end

  self.elements[last] = element
end

function List:RemoveLast()
  if (self:IsEmpty()) then
    LogError("Tried to remove last from empty list.")
    return nil
  end 

  local element = self.elements[self.last]

  self.elements[last] = nil
  self.last = self.last - 1
  return element
end

function List:IsEmpty()
  return self.first == self.last
end

function List:RemoveFirst()
  if (self:IsEmpty()) then
    LogError("Tried to remove first from empty list.")
    return nil
  end
  
  local element = self.elements[self.first]

  self.elements[first] = nil
  self.first = self.first + 1
  return element
end
