require "map/map_point"

UI = {}
UI.__index = UI

background_img = nil
background_quad = nil

selected_char = nil
selected_skill = nil

move_to_cells = {}

is_controlable = true
is_move_mode = false

function UI.Init()
  love.graphics.setBlendMode("alpha")
  background_img = love.graphics.newImage('assets/background/grass.jpg')
  background_quad = love.graphics.newQuad(0, 0, background_width, background_height, background_img:getDimensions())
end

function UI.Draw(map)
  UI.DrawBackground()
  UI.DrawGrid()
  UI.DrawCharacters(map)
  UI.ColorSelectedCharCell()
  UI.DrawCharacterMoves(selected_char, map)
  UI.DrawMouseOverSquare()
  UI.DrawSkills()
  UI.ColorSelectedSkill()
end

function UI.SelectChar(char)
  selected_char = char
  move_to_cells = nil
end

function UI.UnselectChar()
  selected_char = nil
  move_to_cells = nil
end

function UI.SelectSkill(skill)
  selected_skill = skill
end

function UI.UnselectSkill()
  selected_skill = nil
end

function UI.EnableControl()
  is_controlable = false
  love.mouse.setVisible(true)
end

function UI.DisableControl()
  is_controlable = true
  love.mouse.setVisible(false)
end

function UI.MousePressed(x, y, map)
  if not selected_char then
    UI.MousePressedNormal(x, y, map)
  elseif selected_char and not selected_skill then
    UI.MousePressedSelectedChar(x, y, map)
  elseif selected_char and selected_skill then
    UI.MousePressedSelectedSkill(x, y, map)
  end
end 

-- PRIVATE --

function UI.MousePressedNormal(x, y, map)
  cell_x, cell_y = get_cell_in(x, y)
  char_on_place = map:GetChar(cell_x, cell_y)
  if not char_on_place or not char_on_place.is_player_controlled then return end

  UI.SelectChar(char_on_place)
end

function UI.MousePressedSelectedChar(x, y, map)
  cell_x, cell_y = get_cell_in(x, y)
  char_on_place = map:GetChar(cell_x, cell_y)
  
  if char_on_place and char_on_place.is_player_controlled then
    UI.SelectChar(char_on_place)
    return
  end
  if CharCanMoveThere(selected_char, map, cell_x, cell_y) then
    map:MoveChar(selected_char, cell_x, cell_y)
    UI.UnselectChar()
    UI.DisableControl()
    return
  end

  pressed_skill = UI.GetSkillForChar(x, y, selected_char)
  
  if pressed_skill then
    UI.SelectSkill(pressed_skill)
  end
end

function UI.MousePressedSelectedSkill(x, y, map)
end

function UI.GetSkillForChar(x, y, char)
  if not char or not char.skills then return nil end
  if y < background_height + skill_icon_padding or y > background_height + skill_icon_padding + skill_icon_width then
    return nil
  end

  icon_number = math.floor(x / (skill_icon_padding + skill_icon_width)) + 1
  place_in_icon_and_padding = x % (skill_icon_padding + skill_icon_width)
  if place_in_icon_and_padding <= skill_icon_padding then
    return nil
  end

  return char.skills[icon_number]
end

function UI.DrawCharacterMoves(char, map)
  if not char then return end
  if not move_to_cells then move_to_cells = map:GetCharMoveblePoints(char.cell_x, char.cell_y) end
  
  for cell_hash, cell_info in pairs(move_to_cells) do
    UI.ColorCell(cell_info.point.cell_x, cell_info.point.cell_y, 0, 0, 150, 100)
  end
end

function UI.DrawGrid()
  love.graphics.setColor(0, 0, 255)
  love.graphics.setLineWidth(1)
  for i = 1, vertical_cells - 1, 1
  do
    love.graphics.line(0, i * (cell_size + 1), background_width, i * (cell_size + 1))
  end
  for i = 1, horizontal_cells - 1, 1
  do
    love.graphics.line(i * (cell_size + 1), 0, i * (cell_size + 1), background_height)
  end
end

function UI.DrawBackground()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(background_img, background_quad, 0, 0)
end

function UI.DrawMouseOverSquare()
  cell_x, cell_y = get_cell_in(love.mouse.getPosition())
  UI.DrawMouseOverChar(cell_x, cell_y)
  UI.DrawMouseOverMovableSquares(cell_x, cell_y)
end

function UI.DrawMouseOverChar()
end

function UI.DrawMouseOverMovableSquares()
end

function UI.DrawCharacters(map)
  map:DrawChars()
end

function UI.ColorSelectedCharCell()
  if (not selected_char) then return end
  UI.ColorCell(selected_char.cell_x, selected_char.cell_y, 150, 0, 0, 100)
end

function UI.ColorSelectedSkill()
  if not selected_char or not selected_skill then return end
  UI.ColorSkill(selected_char, selected_skill, 150, 150, 0, 100)
end

function UI.ColorCell(cell_x, cell_y, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  x1, y1, x2, y2 = get_cell_coordinates(cell_x, cell_y)
  love.graphics.rectangle("fill", x1, y1, cell_size, cell_size)
end

function UI.ColorSkill(char, skill, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  x1, y1 = UI.GetSkillCoordinates(char, skill)
  love.graphics.rectangle("fill", x1, y1, skill_icon_width, skill_icon_width)
end

function UI.GetSkillCoordinates(char, skill)
  for i, this_skill in pairs(char.skills) do
    if this_skill == skill then
      x = (i - 1) * (skill_icon_padding + skill_icon_width) + skill_icon_padding
      y = background_height + skill_icon_padding
      return x, y
    end
  end
  
  LogError("Character does not have a provided skill in get skill coordinates")
  LogError("Char")
  LogError(char)
  LogError("Skill")
  LogError(skill)
  
  return nil
end

function UI.DrawSkills()
  if not selected_char or not selected_char.skills then return end
  left_padding = skill_icon_padding
  for i, skill in pairs(selected_char.skills) do
    skill:Draw(left_padding, background_height + skill_icon_padding)
    left_padding = left_padding + skill_icon_width + skill_icon_padding
  end
end
