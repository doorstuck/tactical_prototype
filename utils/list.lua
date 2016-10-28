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

function List:At(index)
  if index < 0 or index >= self:GetLenght() then
    LogInfo("tried to get index " .. index " from list that is invalid")
    return nil
  end

  local actual_index = self.first + index
  return self.elements[actual_index]
end

function List:IndexOf(element_to_find)
  for index, element in pairs(self.elements) do
    if element == element_to_find then
      return index - self.first
    end
  end

  return -1
end

function List:RemoveAt(index)
  if index < 0 or index >= self:GetLength() then
    LogError("Tried to remove index " .. index .. " from list. Out of bounds")
  end

  local i = index + self.first

  while i < self.last do
    self.elements[i] = self.elements[i + 1]
    i = i + 1
  end

  self.elements[self.last] = nil
  self.last = self.last - 1
end

function List:Remove(element)
  local index = self:IndexOf(element)
  self:RemoveAt(index)
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
